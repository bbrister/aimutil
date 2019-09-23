function closestDcmName = dcmGetSliceFromCoord(z, dirName)
% Given a directory of DICOM files, return the one closest to the given
% z-coordinate. Throws an error if there is a tie.

% Get all the dicom files in the directory
dcmFiles = dir(fullfile(dirName, '*.dcm'));
numFiles = length(dcmFiles);
if numFiles < 1
    error(['No .dcm files found in ' dirName])
end

% Get the z-coordinates of all the dicom files
zCoords = zeros(numFiles, 1);
for i = 1 : numFiles

    % Check if the file exists. It could be a broken link.
    dcmName = fullfile(dirName, dcmFiles(i).name); 
    if ~exist(dcmName, 'file')
        warning(['File ' dcmNmae ' does not exist! Could be a broken '...
            'symlink'])
        zCoords(i) = nan;
        continue
    end
    
    info = dicominfo(dcmName);
    zCoords(i) = info.ImagePositionPatient(3);
    
    if i == 1
        sliceThickness = info.SliceThickness;
    elseif info.SliceThickness ~= sliceThickness
        error(['Inconsistent slice thickness in directory' dirName])
    end
end

% Check if there are any valid files
if all(isnan(zCoords))
    ME = MException('aimutil:noFiles', ...
        'No valid files found!');
    throw(ME)
end

% Find the closest one
zDists = abs(zCoords - z);
minZDist = min(zDists);
if minZDist > sliceThickness
    error(['Failed to find a z-coordinate in directory ' dirName])
end

matches = find(zDists == minZDist);
if length(matches) > 1
   error(['Multiple matches found in directory ' dirName])
end

closestDcmName = fullfile(dirName, dcmFiles(matches(1)).name);

end