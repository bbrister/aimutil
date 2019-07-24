classdef nnHasher < dataHasher
    % Subclass of dataHasher which stores the output of a neural network
    
    methods
        function self = nnHasher(dirname)
            self = self@dataHasher(dirname);
        end
        
        function data = get(self, inString)
            % See superclass, getInString().
            data = self.get@dataHasher(inString);
        end
        
        function put(self, inString, data)
            % See superclass, getInString().
            self.put@dataHasher(inString, data);
        end
        
        function inString = getInString(self, image, units, nnString)
            % Identifies the input by image, units, and a
            % string giving the info about the neural network. 
            [imageStr, offset, scale] = array2char(image);
            imageHash = self.hash(imageStr);
            inString = [nnString mat2str(units) ...
                mat2str(size(image)) num2str(offset) num2str(scale) ...
                imageHash];
        end
        
        function hashStr = hash(self, inString)
            % From superclass
            hashStr = self.hash@dataHasher(inString);
        end
        
        function tf = hasData(self, inString)
            % From superclass
            tf = self.hasData@dataHasher(inString);
        end
    end
end

