classdef registrationHolder < handle
    % Stores image registrations.
    
    properties
        images
        peakThresh
        keypoints % indexed according to imageHolder
        descriptors % indexed according to keypoints
        coords % indexed just as descriptors
        matches % 2D cell, indexed according to imageHolder. Each element is an N x 2 array of indices in coords
        transforms % 2D cel, indexed just as matches
    end
    
    methods
        
        function self = registrationHolder(imageH, peakThresh)
            % Instantiate a registration holder. imageH must be an
            % imageHolder object
            if ~isa(imageH, 'imageHolder')
                error('imageH must be an imageHolder object')
            end
            self.images = imageH;
            self.coords = {};
            self.keypoints = {};
            self.descriptors = {};
            self.matches = {};
            self.transforms = {};
            self.peakThresh = peakThresh;
            
            % Default parameters
            if nargin < 2
                self.peakThresh = [];
            end
        end
        
        function [keys, desc, coords] = getSift(self, name)
            % Run SIFT on an image, unless it was already done, in which
            % case return the result.
            
            % Make sure the image is loaded
            self.images.get(name);
            
            % Check if we've already processed this image
            imIdx = self.images.index(name);
            if imIdx <= length(self.keypoints) && ...
                    ~isempty(self.keypoints{imIdx})
                keys = self.keypoints{imIdx};
                desc = self.descriptors{imIdx};
                coords = self.coords{imIdx};
                return
            end
            
            % Run SIFT
            [im, units] = self.images.get(name);
            keys = detectSift3D(im, 'units', units, 'peakThresh', ...
                self.peakThresh);
            [desc, coords] = extractSift3D(keys);
            
            % Save the result
            self.keypoints{imIdx} = keys;
            self.descriptors{imIdx} = desc;
            self.coords{imIdx} = coords;
        end
        
        function [matchedCoords1, matchedCoords2] = match(self, name1, ...
                name2)
            % Performing matching on this pair of images, unless it was
            % already done, in which case return the result.
            
            % Get the SIFT descriptors
            [~, desc1, coords1] = self.getSift(name1);
            [~, desc2, coords2] = self.getSift(name2);
            
            % Get the image indices
            idx1 = self.images.index(name1);
            idx2 = self.images.index(name2);
            assert(isscalar(idx1))
            assert(isscalar(idx2))
            
            % Retrive the previous matches for this case (could be empty)
            matchIdx = [];
            if idx1 <= size(self.matches, 1) && ...
                    idx2 <= size(self.matches, 2)
                matchIdx = self.matches{idx1, idx2};
            end
            
            % Perform matching if the matches are missing
            if isempty(matchIdx)
                % Perform matching
                matchIdx = matchSift3D(desc1, coords1, desc2, coords2);
                
                % Use a special flag if there weren't any matches
                if isempty(matchIdx)
                    matchIdx = nan;
                end
                
                % Save the results
                self.matches{idx1, idx2} = matchIdx;
                self.matches{idx2, idx1} = fliplr(matchIdx);
            end
            
            % Quit if no matches were found
            if isnan(matchIdx)
                warning(['Failed to find any matches between '...
                    'series ' name1 ' and ' name2])
                matchedCoords1 = [];
                matchedCoords2 = [];
                return
            end
            
            % Return the matched coordinates
            matchedCoords1 = coords1(matchIdx(:, 1), :);
            matchedCoords2 = coords2(matchIdx(:, 2), :);
        end
    end
end