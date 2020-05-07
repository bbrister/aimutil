function [minCoords, maxCoords] = boundingBox(bw)
% Get the minimum and maximum coordinates of the true elements in bw.
% These are 1-indexed.

ndim = ndims(bw);
[coords{1 : ndim}] = ind2sub(size(bw), find(bw));
coords = cell2mat(coords);

minCoords = zeros(ndim, 1);
maxCoords = zeros(size(minCoords));
for d = 1 : ndim
    dimCoords = coords(:, d);
    minCoords(d) = min(dimCoords);
    maxCoords(d) = max(dimCoords);
end

end