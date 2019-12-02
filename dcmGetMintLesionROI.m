function [pts, mask, slice] = dcmGetMintLesionROI(dirName, lesion)
% Convert the lesion annotation to image space, loading the image if it's
% not provided. mask is a 2D slice--use pts to get the 3D index.

% Make sure the transformation is diagonal (otherwise I don't know what to
% do!)
if ~isdiag(lesion.matIm2mm(1:3, 1:3))
   error('Transformation matrix is not diagonal!') 
end
tform = diag(lesion.matIm2mm);

% Extract the z coordinate
zWorld = lesion.matIm2mm(3, 4);

% Get the corresponding dicom image
try
    dcmName = dcmGetSliceFromCoord(zWorld, dirName); % Throws aimutil:noFiles
catch ME
    if ~strcmp(ME.identifier, 'aimutil:noFiles')
        
    else
       rethrow(ME) 
    end
end
slice = imRead3D(dcmName);

% Get the X-Y units from the dicom image
[~, units] = imRead3D(dcmName);
unitsXY = units(1:2);
clear units

% Make sure the xy tranformation matches the units
if norm(unitsXY - abs(tform(1:2))) > 1e-2
    error('Transformation matrix does not match the units!')
end

% Find the x and y indices of each control point, convert to indices
xyWorld = lesion.pointsMm;
xyIdx = bsxfun(@times, xyWorld, 1 ./ unitsXY');

% Reflect each axis if it's specified in the transformation matrix
pts = zeros(size(xyIdx));
for i = 1 : 2
    if lesion.matIm2mm(i, i) < 0
        pts(:, i) = size(slice, i) - xyIdx(:, i);
    else
        pts(:, i) = xyIdx(:, i);
    end
end

% Early termination
if nargout < 2
    mask = [];
    return
end

% Draw the binary image mask
switch lower(lesion.type)
    case 'polygon'
        mask = poly2mask(pts(:, 1), pts(:, 2), size(slice, 1), ...
            size(slice, 2));
    case 'circle'
        assert(size(pts, 1) == 2)
        center = fliplr(mean(pts(:, 1:2))) + 1;
        radius = norm(pts(1, 1:2) - pts(2, 1:2)) / 2;
        mask = ballMask([size(slice, 1) size(slice, 2)], center, radius);
    case 'cross'
        mask = bwconvhull(poly2mask(pts(:, 1), pts(:, 2), ...
            size(slice, 1), size(slice, 2)));
    otherwise
        error(['Unrecognnized drawing type: ' lesion.type])
end

% Flip the mask at the end--to handle Matlab vs. SIFT3D conventions
mask = mask';

end