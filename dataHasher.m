classdef dataHasher < handle
    % Stores and retrieves data using a single string
   properties(Access = private)
      mDirname
   end
   
   methods
       function self = dataHasher(dirname)
          self.mDirname = dirname;
       end
       
       function tf = hasData(self, inString)
           % Check if the corresponding input data is in the hash tabl.
          filename = self.getFilename(inString);
          tf = exist(filename, 'file');
       end
       
       function data = get(self, inString)
           % Gets the data cooresponding to the input string. Throws an
           % exception if there is none
           if ~self.hasData(inString)
               throw(MException('dataHasher:notFound', ['Could not ' ...
                   'find input ' inString]));
           end
           filename = self.getFilename(inString);
           matRead = load(filename);
           data = matRead.data;
       end
       
       function put(self, inString, data)
           % Hashes the input string and writes the data
           save(self.getFilename(inString), 'data');
       end
       
       function filename = getFilename(self, inString)
           hashString = self.hash(inString);
           filename = fullfile(self.mDirname, [hashString '.mat']);
       end
       
       function hashString = hash(self, inString)
          hashString = char(mlreportgen.utils.hash(inString)); 
       end
   end
end