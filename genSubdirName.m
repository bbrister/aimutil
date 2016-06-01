function fullName = genSubdirName(dirName)
%genSubdirName generate the full name of a subdirectory of this script

% Get the name of the parent directory of this script
parentDir = fileparts(mfilename('fullpath'));

% Get the full name of the directory
fullName = fullfile(parentDir, dirName);

end