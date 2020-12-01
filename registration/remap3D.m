function warped = remap3D(coordMap, im, interp)
% As invAffine3D, but applies an [MxNxPx3] remapping. coordMap comes from 
% computeCoordMap(), which takes in the desired output size.

% Default parameters
if nargin < 4 || isempty(interp)
   interp = 'linear'; 
end

% Reshape the coordinates to linear indices
Xp = extractCoordVec(coordMap, 1);
Yp = extractCoordVec(coordMap, 2);
Zp = extractCoordVec(coordMap, 3);
outSiz = [size(coordMap, 1) size(coordMap, 2) size(coordMap, 3)];

% Warp the image
warped = reshape(interp3(im, Yp, Xp, Zp, interp, 0), outSiz);

end

function coordVec = extractCoordVec(coordMap, dim)

coordVec = coordMap(:, :, :, dim) + 1;
coordVec = reshape(coordVec, [numel(coordVec) 1]);

end
