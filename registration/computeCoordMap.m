function coordMap = computeCoordMap(A, siz)
%COMPUTECOORDMAP compute the coordinates of warping an array of size 'siz'
% by affine transformation matrix A

% Compute the coordinates
[Y, X, Z] = meshgrid(1 : siz(2), 1 : siz(1), 1 : siz(3));
coords = [X(:) Y(:) Z(:)]' - 1;
warpedCoords = A * [coords; ones(1, size(coords, 2))];

% Reshape to a coordinate map
coordMap = zeros([siz 3]);
for i = 1 : 3
    coordMap(:, :, :, i) = reshape(warpedCoords(i, :), siz);
end

end

