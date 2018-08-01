function [filenames, infos] = dcmGetMajorityAcquisition(dirName)
% Read all the dicom files in the directory, and return the names of the
% files sharing the majority acquisition number

% Convert to absolute path
if dirName(1) ~= '/'
    dirName = fullfile(pwd, dirName);
end

% Get the acquisition numbers
dirents = dir(dirName);
numFiles = length(dirents);
filenames = cell(numFiles, 1);
infos = cell(numFiles, 1);
accNums = nan(numFiles, 1);
for k = 1 : numFiles
    thisDirent = dirents(k);
    filename = fullfile(dirName, thisDirent.name);
    
    % Skip non-dicom files
    [~, ~, ext] = fileparts(thisDirent.name);
    if ~strcmp(ext, '.dcm')
        continue
    end
    
    % Get the acquisition number
    info = dicominfo(filename);
    if isfield(info, 'AcquisitionNumber')
        accNums(k) = info.AcquisitionNumber;
    end
    filenames{k} = filename;
    infos{k} = info;
end

% Only return the valid dicom files
valid = ~cellfun(@isempty, filenames);
accNums = accNums(valid);
filenames = filenames(valid);
infos = infos(valid);

% Get the unique acquisition numbers, quit if there are less than 2
uniqueAccs = sort(unique(accNums), 'ascend');
uniqueAccs = uniqueAccs(~isnan(uniqueAccs));
if length(uniqueAccs) < 2
    return
end 

% Count the acquisition numbers, find the majority
counts = histc(accNums, uniqueAccs);
[~, maxIdx] = max(counts);
majorityAcc = uniqueAccs(maxIdx);

% Remove all files from other acquisitions
keepFiles = accNums == majorityAcc;
filenames = filenames(keepFiles);
infos = infos(keepFiles);

end