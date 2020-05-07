function [d, idx] = maskDiameter(mask, units)
% Get the diameter of a binary image.

if nargin < 2 || isempty(units)
    units = [1 1 1];
end
if ~isrow(units)
    units = units';
end

dim = ndims(mask);
switch dim
    case 2
        [X, Y] = meshgrid(1 : size(mask, 2), 1 : size(mask, 1));
        pts = [X(mask) Y(mask)];
    case 3
        [X, Y, Z] = ndgrid(1 : size(mask, 1), 1 : size(mask, 2), ...
            1 : size(mask, 3));
        pts = [X(mask) Y(mask) Z(mask)];
    otherwise
        error(['Unsupported dimensionality ' num2str(dim)])
end

% Multiply points by units
pts = bsxfun(@times, pts, units);

[d, diamIdx] = diameter(pts);
maskIdx = find(mask);
idx = maskIdx(diamIdx);

end