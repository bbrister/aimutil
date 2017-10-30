function [pts, mask] = dcmGetMintLesionROI(dirName, lesion, im, units)
% Convert the lesion annotation to image space, loading the image if it's
% not provided. mask is a 2D slice--use pts to the get 3D index.

% Load the image if it wasn't provided
if nargin < 4
    [im, units] = imRead3D(dirName);
end

% Make sure the transformation is diagonal (otherwise I don't know what to
% do!)
if ~isdiag(lesion.matIm2mm(1:3, 1:3))
   error('Transformation matrix is not diagonal!') 
end
tform = diag(lesion.matIm2mm);

% Make sure the xy tranformation matches the units
if ~isequal(units(1:2), abs(tform(1:2)))
    error('Transformation matrix does not match the units!')
end

% Extract the z coordinate
zWorld = lesion.matIm2mm(3, 4);

% Get the corresponding dicom image
dcmName = dcmGetSliceFromCoord(zWorld, dirName);
slice = imRead3D(dcmName);

% Find the image position in the series
zIdx = sliceGetZ(slice, im);

% Find the x and y indices of each control point, convert to indices
xyWorld = lesion.pointsMm;
xyIdx = bsxfun(@times, xyWorld, 1 ./ units(1 : 2)');

% Reflect each axis if it's specified in the transformation matrix
xyReflectIdx = zeros(size(xyIdx));
assert(ndims(im) == 3)
for i = 1 : 2
    if lesion.matIm2mm(i, i) < 0
        xyReflectIdx(:, i) = size(im, i) - xyIdx(:, i);
    else
        xyReflectIdx(:, i) = xyIdx(:, i);
    end
end

% Form the final indices
pts = [xyReflectIdx repmat(zIdx, [size(xyReflectIdx, 1) 1])];

% Draw the binary image mask
switch lower(lesion.type)
    case 'polygon'
        mask = poly2mask(pts(:, 1), pts(:, 2), size(im, 1), size(im, 2));
    case 'circle'
        assert(size(pts, 1) == 2)
        center = fliplr(mean(pts(:, 1:2))) + 1;
        radius = norm(pts(1, 1:2) - pts(2, 1:2)) / 2;
        mask = ballMask([size(im, 1) size(im, 2)], center, radius);
    case 'cross'
        mask = bwconvhull(poly2mask(pts(:, 1), pts(:, 2), size(im, 1), ...
            size(im, 2)));
    otherwise
        error(['Unrecognnized drawing type: ' lesion.type])
end

end