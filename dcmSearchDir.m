function dcmName = dcmSearchDir(dirName, SOPInstanceUID)
%dcmSearchDir recursively search a directory for a dicom file, by the
%SOPInstanceUID. Returns the first match.

% Verify inputs
if nargin < 1 || isempty(dirName)
    error('dirName not specified')
end

if ~isa(dirName, 'char')
    error('dirName must be a string')
end

if nargin < 2 || isempty(SOPInstanceUID)
    error('SOPInstanceUID not specified')
end

if ~isa(SOPInstanceUID, 'char')
    error('SOPInstanceUID must be a string')
end

disp(['Searching ' dirName ' for SOPInstanceUID ' SOPInstanceUID  '...'])

% Search the DICOM files in this directory
dcmFiles = dir(fullfile(dirName, '*.dcm'));
dcmName = [];
for i = 1 : numel(dcmFiles)
    
    % Form the full file path
    dcmPath = fullfile(dirName, dcmFiles(i).name);
    
    % Read DICOM header
    info = dicominfo(dcmPath);
    
    % Check for a match
    if (strcmp(SOPInstanceUID, info.SOPInstanceUID))
        dcmName = dcmPath;
        return;
    end
end

% Get all the files in this directory
files = dir(dirName);
for i = 1 : numel(files)
   % Search for subdirectories
   file = files(i);
   if ~file.isdir || strcmp(file.name, '.') || strcmp(file.name, '..')
       continue
   end
   
   % Get the full path name of the subdirectory
   subdirName = fullfile(dirName, file.name); 
   
   % Recursively search the subdirectory
   dcmName = dcmSearchDir(subdirName, SOPInstanceUID);
   
   % Quit if we have found a match
   if ~isempty(dcmName)
       return
   end
end

end