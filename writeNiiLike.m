function writeNiiLike(path_out, im, units, path_like)
% Writes a Nifti to path_out with the same header and datatype as 
% path_like. Uses python with nibabel.

% Get the python command
thisDir = fileparts(mfilename('fullpath'));
pythonScript = fullfile(thisDir, 'transferNiftiHeader.py');
if ~exist(pythonScript, 'file')
    error(['Failed to find ' pythonScript])
end

imWrite3D(path_out, im, units)
ret = runCmd(['python ' pythonScript ' ' path_out ' ' path_like]);
if ret ~= 0
    error(['Failed with code ' num2str(ret)])
end