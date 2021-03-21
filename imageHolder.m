classdef imageHolder < handle
    % Stores images. Loads them if they aren't already present in memory.
    % This will never delete images, so the indices are persistent.
    
    properties
        paths
        images
        units
    end
    
    methods
        
        function self = imageHolder(self)
            self.paths = {};
            self.images = {};
            self.units = {};
        end
        
        function [im, units] = get(self, name)
            % Load a directory. Adds it to the list if present
            
            % Check if we have the image. If so return it.
            path = absPath(name);
            matchIdx = self.index(name);
            if ~isempty(matchIdx)
                
                im = self.images{matchIdx};
                units = self.units{matchIdx};
                return
            end
            
            % Read the image, using the majority acquisition
            try
                [im, units] = dcmReadFiles(dcmGetMajorityAcquisition(path));
            catch ME
               warning(['Received an error reading image from ' path ...
                   '...']) 
               rethrow(ME)
            end
            
            % Add the image to the list
            self.paths{end + 1} = path;
            self.images{end + 1} = im;
            self.units{end + 1} = units;
        end
        
        function idx = index(self, name)
            % Returns the index of this image in the storage, or empty if
            % it does not exist
            path = absPath(name);
            idx = find(strcmp(path, self.paths));
            
            % Make sure we don't have 2 copies of the image
            assert(isempty(idx) || isscalar(idx))
        end
    end
end