function lut = loadLUT(lutName)

% Default arguments
if nargin < 1 || isempty(lutName)
    lutName = fullfile(tempName(), 'lut.mat');
end


% Load the lookup table from a file
load(lutName);
if ~isa(lut, 'DicomLUT')
    error('LUT is not a member of the DicomLUT class')
end

end