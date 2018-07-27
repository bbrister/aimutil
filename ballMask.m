function mask = ballMask(siz, center, radius, units)
% Make an ball mask with the desired center and radius

if nargin < 4 || isempty(units)
    units = [1 1 1];
end

% Normalize the center, in mm
nCenter = center .* units;

dim = length(siz);
switch dim
    case 2
    [X, Y] = meshgrid(1 : siz(2), 1 : siz(1));
    X = X * units(1);
    Y = Y * units(2);
    mask = (X - nCenter(2)) .^ 2 + (Y - nCenter(1)) .^ 2 <= radius ^ 2; 
    case 3
    [X, Y, Z] = ndgrid(1 : siz(1), 1 : siz(2), 1 : siz(3));
    X = X * units(1);
    Y = Y * units(2);
    Z = Z * units(3);
    mask = (X - nCenter(1)) .^ 2 + (Y - nCenter(2)) .^ 2  + ...
        (Z - nCenter(3)) .^ 2 <= radius ^ 2; 
    otherwise
        error(['Unsupported dimensionality: ' num2str(dim)])
end

end

