function [diam, idx] = diameter(X)
% Find the diameter of an [mxn] point set X, where m is the number of
% points, and n is the dimensionality. 
%
% Return values:
%   diam - The diameter.
%   idx - The indices in X of a pair of points forming a diameter.

% Check for degenerate cases
if isempty(X)
    diam = 0;
    idx = [];
    return
elseif size(X, 1) == 1
    % Check for a single point
    diam = 0;
    idx = 1;
    return
elseif size(X, 2) == 3 && length(unique(X(:, 3))) == 1
    % Check for 3D points that lie in a single axial plane (Could be
    % generalized to applying a rigid transform to take a coplanar set 
    % to the axial plane)
    X = X(:, 1:2);
end

% Take the convex hull to remove unnecessary points
try
    if size(X, 1) == 2
        XHullIdx = 1 : size(X, 1);
    else
        XHullIdx = unique(convhull(X, 'simplify', true));
    end
catch ME
    switch ME.identifier
        case 'MATLAB:convhull:EmptyConvhull2DErrId' % 2D collinear points
            XHullIdx = 1 : size(X, 1);
        case 'MATLAB:convhull:EmptyConvhull3DErrId' % 3D collinear points
            XHullIdx = 1 : size(X, 1);
        case 'MATLAB:convhull:NotEnoughPtsConvhullErrId' % Too few points
            XHullIdx = 1 : size(X, 1);
        otherwise
            keyboard
            rethrow(ME)
    end
end

% Exhaustive search (note: faster algorithms are known)
dist = squareform(pdist(X(XHullIdx, :)));
[rowDiams, rows] = max(dist);
[diam, col] = max(rowDiams);
hullIdx = [rows(col) col];
idx = XHullIdx(hullIdx);

end