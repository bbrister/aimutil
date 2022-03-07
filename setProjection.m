function [dist, Aidx, Bidx] = setProjection(siz, Ainds, Binds, units)
% In a binary array of size 'siz', find the projection of the set Ainds
% onto Binds. The pair (Aidx, Bidx) gives the nearest matching pair, which
% of course may not be unique.
%
% If 'units' is specified, performs an isotropic transform before taking
% the distance.

% Default units
if nargin < 4 || isempty(units)
    units = ones(size(siz));
end

% Check for empty sets
if isempty(Ainds) || isempty(Binds)
    warning('Received empty set. Returning inf')
    dist = inf;
    Aidx = [];
    Bidx = [];
    return 
end

% Check for intersection, to speed up computation
intersection = intersect(Ainds, Binds);
if ~isempty(intersection)
    Aidx = intersection(1);
    Bidx = Aidx;
    dist = 0;
    return
end

% Normalize 'units' so their minimum is 1 voxel
normFactor = min(units(:));
normUnits = units / normFactor;

% Convert the size and indices using the units
[normAinds, normSiz] = remapInds(Ainds, siz, normUnits);
[normBinds, normSiz2] = remapInds(Binds, siz, normUnits);
assert(isequal(normSiz, normSiz2));

% Run the helper function, which doesn't know about units
[normDist, normAidx, normBidx] = setProjectionHelper(normSiz, normAinds, normBinds);

% Normalize the returns back to the orginal units
dist = normDist * normFactor;
Aidx = Ainds(normAinds == normAidx);
Bidx = Binds(normBinds == normBidx);
assert(length(Aidx) == 1)
assert(length(Bidx) == 1)

end


function [dist, Aidx, Bidx] = setProjectionHelper(siz, Ainds, Binds)

% Convert to subscripts
ndim = length(siz);
[Asubs{1:ndim}] = ind2sub(siz, Ainds);
[Bsubs{1:ndim}] = ind2sub(siz, Binds);
Asubs = cell2mat(Asubs);
Bsubs = cell2mat(Bsubs);

% Get the overall bounding box
bounds = boundingBox(siz, [Asubs; Bsubs]);

% Adjust the subscripts, sizes for the bounding box
subsOffset = bounds(1, :) - 1;
bbSiz = bounds(2, :) - bounds(1, :) + 1;

% Convert to indices in the bounding box
bbAinds = convertInds(Ainds, siz, bbSiz, subsOffset);
bbBinds = convertInds(Binds, siz, bbSiz, subsOffset);

% Take the distance transform of B within the bounding box
bbMaskB = false(bbSiz);
bbMaskB(bbBinds) = true;
[bbDistB, bbProjIdxB] = bwdist(bbMaskB);

% Restrict the distance transform to the set A
bbDistBrestrictA = bbDistB(bbAinds);
bbProjIdxBrestrictA = bbProjIdxB(bbAinds);

% Find the nearest match (may not be unique)
[dist, minIdx] = min(bbDistBrestrictA);
bbMinAidx = bbAinds(minIdx);
bbMinBidx = bbProjIdxBrestrictA(minIdx);

% Convert the indices back to the full array
Aidx = convertInds(bbMinAidx, bbSiz, siz, -subsOffset);
Bidx = convertInds(bbMinBidx, bbSiz, siz, -subsOffset);

end

function newInds = convertInds(oldInds, oldSiz, newSiz, subsOffset)
% Convert indices from oldSiz to newSiz. Must be contained in newSiz.
ndim = length(oldSiz);
[oldSubs{1 : ndim}] = ind2sub(oldSiz, oldInds);
oldSubs = cell2mat(oldSubs);
newSubs = bsxfun(@minus, oldSubs, subsOffset);
newSubs = num2cell(newSubs, 1);
newInds = sub2ind(newSiz, newSubs{:});
end

function bounds = boundingBox(siz, coords)
% Coords is an [m x ndim] array

% Convert to subscripts
ndim = length(siz);

% Get the bounding box
bounds = zeros(2, ndim);
for d = 1 : ndim
    dimCoords = coords(:, d);
    bounds(1, d) = min(dimCoords);
    bounds(2, d) = max(dimCoords);
end

end

function [newInds, newSiz] = remapInds(inds, siz, units)
% Remap the indices using the specified units

if isempty(inds)
    newInds = [];
    return
end

% Ensure 'siz' and 'units' are both row vectors
if size(siz) ~= size(units)
    units = units';
end

assert(length(siz) <= 3)
[X, Y, Z] = ind2sub(siz, inds);
X = ceil(X * units(1));
if length(units) >= 2
    Y = ceil(Y * units(2));
end
if length(units) >= 3
    Z = ceil(Z * units(3));
end

newSiz = ceil(siz .* units);
newInds = sub2ind(newSiz, X, Y, Z);

end