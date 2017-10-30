function mask = ballMask(siz, center, radius)
% Make an ball mask with the desired center and radius

dim = length(siz);
switch dim
    case 2
    [X, Y] = meshgrid(1 : siz(2), 1 : siz(1));
    mask = (X - center(2)) .^ 2 + (Y - center(1)) .^2 <= radius ^ 2; 
    case 3
    [X, Y, Z] = ndgrid(1 : siz(1), 1 : siz(2), 1 : siz(3));
    mask = (X - center(1)) .^ 2 + (Y - center(2)) .^2  + ...
        (Z - center(3)) .^ 2 <= radius ^ 2; 
    otherwise
        error(['Unsupported dimensionality: ' num2str(dim)])
end

end

