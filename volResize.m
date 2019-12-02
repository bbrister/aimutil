function vol = volResize(vol, siz, mode, oobVal)
% Resize a 3D volume. Mode is the interpolation mode in interp3.
    % Create the interpolation map
    
    % Do nothing in the trivial case
    if isequal(siz, size(vol))
        return
    end
    
    if nargin < 4 || isempty(oobVal)
        oobVal = 0;
    end
    
    factors = size(vol) ./ siz;
    
    [X, Y, Z] = meshgrid(1 : siz(2), 1 : siz(1), 1 : siz(3));
    X = (X - 1) * factors(1) + 1;
    Y = (Y - 1) * factors(2) + 1;
    Z = (Z - 1) * factors(3) + 1;
    
    vol = interp3(vol, X, Y, Z, mode, oobVal);
    
end