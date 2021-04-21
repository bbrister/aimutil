function foundIntersect = checkSelfIntersection(X, Y)
%checkSelfIntersection(X, Y) returns whether the polygon given by vectors
% X, Y is self-intersecting. Credit for the algorithm goes to:
%
% F. Feito, J.C. Torres, A. Ureña,
% Orientation, simplicity, and inclusion test for planar polygons,
% Computers & Graphics,
% Volume 19, Issue 4,
%
% Credit for the degenerate case is given to:
% http://www.dcs.gla.ac.uk/~pat/52233/slides/Geometry1x1.pdf
% BUT, the orientation test in these slides is incorrect!

% Verify inputs
validateattributes(X, {'numeric'}, {'column'})
validateattributes(Y, {'numeric'}, {'column'})
assert(isequal(size(X), size(Y)))

% Form the list of all line segments
pts = [X Y];
numSegs = length(X);
lineSegs = zeros(numSegs, 4);
for segIdx = 1 : numSegs
    % Get the point inds
    pt1Idx = segIdx;
    pt2Idx = mod(segIdx, numSegs) + 1;
    
    lineSegs(segIdx, :) = [pts(pt1Idx, :) pts(pt2Idx, :)];
end

% Check each line segment, starting with the third
foundIntersect = true;
for segIdx = 3 : numSegs
    % Get the point inds
    pt1Idx = segIdx;
    pt2Idx = mod(segIdx, numSegs) + 1;
    
    % Get the segment
    seg = lineSegs(segIdx, :);
    
    % Get the list of all previous line segments, except the most recent
    % one. If this is the last segment, also remove the first
    segsOther = lineSegs(1 : segIdx - 2, :);
    if segIdx == numSegs
        if size(segsOther, 1) > 1
            segsOther = segsOther(2, :);
        else
            continue % All other segments contain this point
        end
    end
    if isempty(segsOther)
        break
    end
    
    % Get the sets of triangles
    numTri = size(segsOther, 1);
    repSeg = repmat(seg, [numTri 1]);
    tri = zeros(numTri, 6, 4); % Four sets of triangles
    tri(:, :, 1) = [repSeg segsOther(:, [1 2])]; % First point of other
    tri(:, :, 2) = [repSeg segsOther(:, [3 4])]; % Second point of other
    tri(:, :, 3) = [segsOther repSeg(:, [1 2])]; % First point of seg
    tri(:, :, 4) = [segsOther repSeg(:, [3 4])]; % Second point of seg
    
    % Compute the orientations
    ori = cellfun(@triOrientation, num2cell(tri, 2));
    ori = permute(ori, [1 3 2]); % Remove the singleton dimension
    
    % Test for intersection--different orientations
    if any(ori(:, 1) ~= ori(:, 2) & ori(:, 3) ~= ori(:, 4))
        foundIntersect = true;
        return
    end
    
    % Test for intersection--collinear segments
    collinearSegs = all(ori == 0, 2);
    if any(collinearSegs(:))
        % Take the degenerate segments
        segsDeg = segsOther(collinearSegs, :);
        
        % Compute the x- and y-projections
        [xMin1, xMax1, yMin1, yMax1] = coordProjs(seg);
        [xMin2, xMax2, yMin2, yMax2] = coordProjs(segsDeg);
        
        % Check for intersection
        intersect = checkIntersect1D(xMin1, xMax1, xMin2, xMax2) & ...
            checkIntersect1D(yMin1, yMax1, yMin2, yMax2);
        
        if any(intersect(:))
            foundIntersect = true;
            return
        end
    end
end

foundIntersect = false;

end

function [xMin, xMax, yMin, yMax] = coordProjs(segs)
% Compute x & y projections of the segments

[xMin, xMax] = minMax(segs(:, [1 3]));
[yMin, yMax] = minMax(segs(:, [2 4]));

end

function [m, M] = minMax(X)

m = min(X, [], 2);
M = max(X, [], 2);

end

function tf = checkIntersect1D(min1, max1, min2, max2)
% Check if the two 1d ranges intersect

tf = (min1 >= min2 & min1 <= max2) | (min1 <= min2 & min2 <= max1);

end

function tf = inConvHull(convHullInds, ptIdx)

tf = ~isempty(intersect(convHullInds, ptIdx));

end

function ori = triOrientation(tri, tol)
% Computes the orientation of a single triangle. Called via cellfun
   
if nargin < 3
    tol = [];
end

validateattributes(tri, {'numeric'}, {'size', [1 6]})

X = tri([1 3 5])';
Y = tri([2 4 6])';
ori = xyOrientation(X, Y, tol);

end

function ori = xyOrientation(X, Y, tol)
% Compute the orientation of the triangle given by (X, Y). Returns 1 for
% CW, -1 for CCW, 0 for collinear. Optional tolerance parameter.

if nargin < 3 || isempty(tol)
    tol = 1e-5;
end

validateattributes(X, {'numeric'}, {'size', [3 1]})
validateattributes(Y, {'numeric'}, {'size', [3 1]})

% Compute the signed area. See https://mathworld.wolfram.com/TriangleArea.html
triDet = det([X Y ones(3, 1)]);

if abs(triDet) < tol
    ori = 0;
else
    ori = sign(triDet);
end

end