function [filename, info] = dcmGetFileFromDir(dirName)
%DCMGETFILEFROMDIR Utility function to get the information from a single 
% Dicom file from a directory. Throws an error if there is no such file.

if ~exist(dirName, 'dir')
    error(['Could not find directory ' dirName])
end

dirents = dir(dirName);
for i = 1 : length(dirents)
   dirent = dirents(i);
   
   % Skip non .dcm files
   [~, ~, ext] = fileparts(dirent.name);
   if ~strcmp(ext, '.dcm')
       continue
   end
   
   % Try 'dicominfo'
   filename = fullfile(dirName, dirent.name);
   try
      info = dicominfo(filename);
   catch
       continue
   end
       
   % Return the file as usable
   return
end

% Failure if we get to this point
filename = [];
info = [];
error(['Failed to find a valid Dicom file in directory ' dirName])

end