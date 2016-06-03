classdef DicomLUT
    %DicomLUT Lookup table for DICOM files
   
    properties (GetAccess=private)
       lut = {}; % Mx2 cell of (name, SOPInstanceUID) pairs
    end
    
    methods
        
        % Return the file names corresponding to an SOPInstanceUID
        function names = lookup(self, SOPInstanceUID)
            names = {};
            for i = 1 : size(self.lut, 1)
                if (strcmp(self.lut{i, 2}, SOPInstanceUID))
                    name = self.lut(i, 1);
                    if (isempty(names))
                        names = name;
                    else
                        names = [names; name];
                    end
                end
            end
        end
        
        % Add a (name, SOPInstanceUID) pair, or do nothing if it is already
        % in the LUT. Returns the new LUT
        function self = add(self, name, SOPInstanceUID)
            
            % Check for duplicates
            if ~isempty(self.probe(name, SOPInstanceUID))
                return
            end
                
            % Add the entry
            entry = {name, SOPInstanceUID};
            if isempty(self.lut)
                % First element
                self.lut = entry;
            else
                % Append to existing elements
                self.lut = [self.lut; entry];
            end
        end
        
        % Remove a (name, SOPInstanceUID) pair, or do nothing if it is not
        % in the LUT. Returns the new LUT
        function self = remove(self, name, SOPInstanceUID)
            
            % Check if the element exists
            idx = self.probe(name, SOPInstanceUID);
            if ~isempty(idx)
                % Remove the element
                self.lut = self.lut([1 : idx - 1, idx + 1 : end], :);
            end
        end
        
        % Returns the index of the element in the internal data structure,
        % or empty if it does not exist
        function idx = probe(self, name, SOPInstanceUID)
            idx = [];
            names = self.lookup(SOPInstanceUID);
            for i = 1 : length(names)
                if strcmp(names{i}, name)
                    idx = [idx; i];
                end
            end
            assert(numel(idx) < 2)
        end
        
        % Returns the internal LUT cell, for debugging purposes
        function lut = getLUT(self)
            lut = self.lut;
        end
    end 
end