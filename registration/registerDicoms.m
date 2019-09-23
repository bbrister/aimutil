function A = registerDicoms(units1, infos1, units2, infos2)
% Register series 1 to series 2, based on the units and DICOM metadata.
% This takes into account the scaling and z-translation. Returns a 3x4
% affine transformation matrix.

% Check the image orientation
%TODO: Get the sorting axis, and use that for firstCoords, not only z
assumedOrientation = [1 0 0 0 1 0]'; % Code only implemented for this one!
assert(isequal(infos1{1}.ImageOrientationPatient, assumedOrientation));
assert(isequal(infos1{1}.ImageOrientationPatient, ...
    infos2{1}.ImageOrientationPatient))

% Get the linear part from the units
lin = diag(units2 ./ units1);

% Get the translation to align the first (bottom) slice in each series
transMm = firstCoords(infos2) - firstCoords(infos1);
transVox = transMm ./ units1;

% Return the transform
A = [lin transVox];

end

function coords = firstCoords(infos)
% Return the coordinates of the first (bottom) slice in the Dicom files

numFiles = length(infos);
Z = nan(numFiles, 1);
for k = 1 : numFiles
   Z(k) = infos{k}.ImagePositionPatient(3);
end

[~, firstIdx] = min(Z);
coords = infos{firstIdx}.ImagePositionPatient;

end