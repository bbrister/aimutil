classdef registrationHasher < dataHasher
    % Subclass of dataHasher which stores the output of a neural network
    
    methods
        function self = registrationHasher(dirname)
            self = self@dataHasher(dirname);
        end
        
        function [match1, match2] = getRegistration(self, dir1, dir2)
            % Get the sorted data
            [inString, order] = self.getInString(dir1, dir2);
            sortedData = self.get(inString);
            
            % Re-order the data, to account for sorting
            match1 = sortedData(:, order(1));
            match2 = sortedData(:, order(2));
        end
        
        function data = get(self, inString)
            % See superclass, get().
            data = self.get@dataHasher(inString);
        end
        
        function putRegistration(self, dir1, match1, dir2, match2)
            % Put the regitration data. match1 and match2 should be vectors
            % of linear indices into the image volumes in dir1, dir2
            
            % Check the input format
            assert(isvector(match1))
            assert(isvector(match2))
            
            % Put the data
            [inString, order] = self.getInString(dir1, dir2);
            inData = [match1 match2];
            orderedData = self.reorderData(inData, order);
            self.put(inString, orderedData)
        end
        
        function put(self, inString, data)
            % See superclass, getInString().
            self.put@dataHasher(inString, data);
        end
        
        function [inString, sortOrder] = getInString(self, dir1, dir2)
            % Given a pair of image directories, extracts the DICOM series
            % UIDs and concatenates them in a string
            
            % Get the UIDs in the order of input arguments
            uid1 = self.getDirUid(dir1);
            uid2 = self.getDirUid(dir2);
            
            % Make an array consisting of the short UID, and the length of
            % the longer UID up to the length of the short one plus one
            sortLength = min(length(uid1), length(uid2));
            arrayToSort = [uid1(1 : sortLength) ' '; ...
                uid2(1 : sortLength) ' '];
            if length(uid1) > sortLength
                arrayToSort(1, end) = uid1(sortLength + 1);
            elseif length(uid2) > sortLength
                arrayToSort(2, end) = uid2(sortLength + 1);
            end
            
            % Sort the UIDs lexicographically, to avoid duplicated entries
            [~, sortOrder] = sortrows(arrayToSort);
            
            % Apply the sorting order to the full UIDs, to ensure
            % uniqueness of hashed keys
            fullUids = {uid1, uid2};
            inString = [fullUids{sortOrder(1)} '-' fullUids{sortOrder(2)}];
        end
        
        function tf = hasRegistration(self, dir1, dir2)
            inString = self.getInString(dir1, dir2);
            tf = self.hasData(inString);
        end
        
        function tf = hasData(self, inString)
            % From superclass. Primal means not inverted.
            tf = self.hasData@dataHasher(inString);
        end
        
        function uid = getDirUid(self, imageDir)
            % Get the DICOM series UID given an image directory
            [~, info] = dcmGetFileFromDir(imageDir);
            uid = info.SeriesInstanceUID;
        end
        
        function outData = reorderData(self, inData, order)
            % Reorders the match matrix
            outData = inData(:, order);
        end
        
        function addMatFiles(self, dirName, siz, tag)
            % Add all the registration.mat files in the given directory. 
            % 'tag' is optional, used to differentiate between versions
            
            % Default tag does nothing
            if nargin < 4
                tag = '';
            end
            
            try
                regFilenames = ls(fullfile(dirName, ...
                    ['registration*_' tag '*.mat']));
            catch ME
                if strcmp(ME.identifier, 'MATLAB:ls:OSError')
                    % This happens when the pattern is not matched
                    warning(['Failed to find registration files in ' ...
                        dirName])
                    return
                else
                    rethrow(ME)
                end
            end
            regFilenames = strsplit(regFilenames);
            regFilenames = regFilenames(~cellfun('isempty', regFilenames));
            
            for i = 1 : length(regFilenames)
                % Load the data
                regFilename = regFilenames{i};
               regData = load(regFilename);
               dir1 = regData.baselineDir;
               dir2 = regData.followupDir;
               
               % Check if we have this registration
               if self.hasRegistration(dir1, dir2)
                   warning(['Found duplicate. Skipping file ' regFilename])
                   continue
               end
               
               % If not, add it
               vec1 = self.subs2lin(siz, regData.baselineMatches + 1);
               vec2 = self.subs2lin(siz, regData.followupMatches + 1);
               self.putRegistration(dir1, vec1, dir2, vec2);
            end
        end
        
        function computeRegistration(self, registrationHolder, dir1, dir2)
            % Compute a new registration and has it. First tries to look
            % up the existing one
            if (self.hasRegistration(dir1, dir2))
                warning('Found duplicate. Skipping registration.')
                return
            end
            
            % Perform registration
            disp('Starting registration...')
            [match1, match2] = registrationHolder.match(dir1, dir2);
            if isempty(match1)
                    keyboard % TODO: we want to cache that the result is empty. Will the existing code work?
            end
            
            % Store the results
            [im1, ~] = registrationHolder.getImage(dir1);
            inds1 = self.subs2lin(size(im1), match1);
            
            [im2, ~] = registrationHolder.getImage(dir2);
            inds2 = self.subs2lin(size(im2), match2);
            
            self.putRegistration(dir1, inds1, dir2, inds2);
            
            % Sanity check
            [storedInds1, storedInds2] = self.getRegistration(dir1, dir2);
            assert(isequal(storedInds1, inds1))
            assert(isequal(storedInds2, inds2))
        end
        
        function inds = subs2lin(self, siz, subs)
            % Utility to convert subscripts to linear indices
            inds = sub2ind(siz, subs(:, 1), subs(:, 2), subs(:, 3));
        end
        
        function subs = lin2subs(self, siz, inds)
            % Utility to convert linear indices to subscripts
            [I, J, K] = ind2sub(siz, inds);
            subs = [I J K];
        end
    end
end

