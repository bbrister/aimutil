classdef nnHasher < dataHasher
    % Subclass of dataHasher which stores the output of a neural network
    
    methods(Static = true)
        
        function [hashStr, offset, scale] = hashImage(image)
            [imageStr, offset, scale] = array2char(image);
            hashStr = dataHasher.hash(imageStr);
        end
        
        function hashStr = hashFile(filename)
           % Hash a binary file. For example, the network .pb file
           fid = fopen(filename);
           data = convertCharsToStrings(char(fread(fid)'));
           fclose(fid);
           hashStr = dataHasher.hash(data);
        end
        
        function inString = getInString(image, units, nnString)
            % Identifies the input by image, units, and a
            % string giving the info about the neural network.
            [imageHash, offset, scale] = nnHasher.hashImage(image);
            inString = [nnString mat2str(units) ...
                mat2str(size(image)) num2str(offset) num2str(scale) ...
                imageHash];
        end
    end
    
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
        
        function tf = hasData(self, inString)
            % From superclass
            tf = self.hasData@dataHasher(inString);
        end
    end
end

