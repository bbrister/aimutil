function [warped, coordMap] = invAffine3D(A, im, siz, interp, maskVal)
% Apply the inverse of a 3D affine transform to an image, with output size
% 'siz'. If provided, 'interp' must be a valid METHOD argument to the
% interp3 function.
%
% If maskVal is provided, use this to create a mask of the input image, and
% warp only this sub-volume for speed.

% Default parameters
if nargin < 4 || isempty(interp)
   interp = 'linear'; 
end

% Verify inputs
assert(ndims(im) == 3)

% Optional masking
if nargin > 4 && ~isempty(maskVal)
    % Compute a bounding cube around the input mask
    [X, Y, Z] = ind2sub(size(im), find(im ~= maskVal));
    bounds = coordsMinMax([X Y Z]);
    minInMask = bounds(1, :);
    maxInMask = bounds(2, :);
    
    % Add one voxel of padding on each end, to enable correct interpolation
    % and prevent collapsing dimensions
    imSiz = size(im);
    minInMask = max(1, minInMask - 1);
    maxInMask = min(imSiz, maxInMask + 1);
    
    % Extract the sub-volume
    subVol = im(minInMask(1) : maxInMask(1), ...
        minInMask(2) : maxInMask(2), minInMask(3) : maxInMask(3));
    
    % Get the corners of this bounding cube
    bbRow = 1;
    bbCorners = zeros(8, 3);
    for xx = 1 : 2
        for yy = 1 : 2
            for zz = 1 : 2
               bbCorners(bbRow, 1) = bounds(xx, 1);
               bbCorners(bbRow, 2) = bounds(yy, 2);
               bbCorners(bbRow, 3) = bounds(zz, 3);
               bbRow = bbRow + 1;
           end
       end
   end
   
   % Warp the bounding cube corners by the INVERSE of A
   bbWarped = max(1, bsxfun(@min, siz, ...
       applyAffine(invertAffine(A), bbCorners, 1)));
   
   % Get the output bounding cube
   warpedBounds = coordsMinMax(bbWarped);
   minOutMask = floor(warpedBounds(1, :));
   maxOutMask = ceil(warpedBounds(2, :));
   subWarpedSiz = maxOutMask - minOutMask + 1;
   
   % Shift the warping matrix A, so the origin of the output is sent to
   % the place where the upper corner of the output bounding cube was sent
   % under A, then shifting to account for the windowed input
   Asub = [A(:, 1:3) applyAffine(A, minOutMask, 1)' - minInMask'];
   
   % Interpolate
   [subWarped, coordMap] = invAffine3D(Asub, subVol, subWarpedSiz, interp);
   
   % Restore the results to the original size
   warped = maskVal * ones(siz);
   warped(minOutMask(1) : maxOutMask(1), minOutMask(2) : maxOutMask(2), ...
       minOutMask(3) : maxOutMask(3)) = subWarped;
   return
end

[Y, X, Z] = meshgrid(1 : siz(2), 1 : siz(1), 1 : siz(3));
coords = [X(:) Y(:) Z(:)]' - 1;
warpedCoords = A * [coords; ones(1, size(coords, 2))];
[warped, coordMap] = remap3D(warpedCoords, im, siz, interp);

end

function bounds = coordsMinMax(coords)

bounds = zeros(2, 3);
for d = 1 : 3
    dimCoords = coords(:, d);
    bounds(1, d) = min(dimCoords);
    bounds(2, d) = max(dimCoords);
end

end
