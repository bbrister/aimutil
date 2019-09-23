function [warped, coordMap] = remap3D(warpedCoords, im, siz, interp)
% As invAffine3D, but applies an [MxNxPx3] remapping

% Default parameters
if nargin < 4 || isempty(interp)
   interp = 'linear'; 
end

% Warp the images
Xp = warpedCoords(1, :) + 1;
Yp = warpedCoords(2, :) + 1;
Zp = warpedCoords(3, :) + 1;
warped = reshape(interp3(im, Yp, Xp, Zp, interp, 0), siz);

% Save the coordinate map
coordMap = zeros([siz 3]);
for i = 1 : 3
    coordMap(:, :, :, i) = reshape(warpedCoords(i, :), siz);
end

end
