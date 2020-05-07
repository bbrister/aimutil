function [dist, Aidx, Bidx] = setProjection(siz, Ainds, Binds)
% In a binary array of size 'siz', find the projection of the set Ainds
% onto Binds. The pair (Aidx, Bidx) gives the nearest matching pair, which
% of course may not be unique.

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