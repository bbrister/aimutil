function ptsWarp = applyAffine(A, pts, firstIdx)
% Apply a [3x4] affine transform to an [Mx3] matrix of points. The 
% transform works on 0-indexed points. If the points are 1-indexed, set 
% firstIdx to 1 (default)
if nargin < 3 || isempty(firstIdx)
    firstIdx = 1;
end
    ptsWarp = (A * [pts - firstIdx, ones(size(pts, 1), 1)]')' + firstIdx;
end