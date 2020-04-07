function sliceFileName = dcmDirGetIm(dirName, im)
%dcmDirGetIm given a directory of DICOMs, find the first file name
% matching the given image data. Must be an exact match. Uses imRead3D to
% read the data.

% Hash the image data
[imHash, imOffset, imScale] = nnHasher.hashImage(im);

% Read all the DICOMs and look for a match
dirents = dir(dirName);
for fileIdx = 1 : length(dirents)
    dirent = dirents(fileIdx);
    
    % Only check .dcm files
    fileBaseName = dirent.name;
    [~, ~, ext] = fileparts(fileBaseName);
    if ~strcmp(ext, '.dcm')
        continue
    end
    
    % Read the file
    filePath = fullfile(dirName, fileBaseName);
    fileImData = imRead3D(filePath);
    
    % Hash the file
    [fileHash, fileOffset, fileScale] = nnHasher.hashImage(fileImData);
    
    % Compare the hashes
    if strcmp(fileHash, imHash) && imOffset == fileOffset && ...
            imScale == fileScale 
        % Double check the matching file (hash is not injective)
        if ~isequal(im, fileImData)
           warning(['Hash collision for file ' fileHash]) 
           continue
        end
            
        % Return the match
        sliceFileName = fullfile(dirName, fileBaseName);
        return
    end
end

% No match found
sliceFileName = [];
warning(['No match found in directory ' dirName])

end

