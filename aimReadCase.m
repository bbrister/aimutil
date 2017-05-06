function [im, units, points] = aimReadCase(aimName, dcmDir, im)
% Read an image and AIM annotation from files.
%
% Parameters:
%   aimName - The name of the AIM file.
%   dcmDir - The directory containing the DICOM files.
%   im - Optionally provide the image. Otherwise it is read from disk.
% 
% Returns:
%   im - See imRead3D.m.
%   units - See imRead3D.m.
%   points - The [Mx3] coordinate matrix of annotation points.

% Read the corresponding DICOM slice
dcmName = aimGetDicom(aimName, dcmDir);
[slice, sliceUnits] = imRead3D(dcmName);

if nargin < 3 || isempty(im)
    % Read the full volume
    [im, units] = imRead3D(dcmDir);
    if ~isequal(sliceUnits, units)
        error(['Slice ' dcmName ' and volume ' dcmDir ...
            ' have different units!'])
    end
else
    units = sliceUnits;
end

% Read the xy coordinates
xy = aimGetPoints(aimName);

% Get the z coordinate
z = sliceGetZ(slice, im);

% Form the points matrix
points = [xy repmat(z, [size(xy, 1) 1])];

end