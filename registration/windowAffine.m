function [A, winSiz] = windowAffine(coordsMin, coordsMax)
% Get an affine transform corresponding to a window around the given points
% coordsMin, coordsMax are 3-vectors defining the cube window in image
% space

% Compute the offset an make a translation (affine) matrix
winOffsets = coordsMin - 1;
A = [eye(3) winOffsets'];
winSiz = coordsMax - winOffsets;

end