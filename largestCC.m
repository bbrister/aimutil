function mask = largestCC(mask, n)
% Take the N largest connected components of a  binary mask

if nargin < 2 || isempty(n)
    n = 1;
end

stats =  regionprops(mask, 'Area', 'PixelIdxList');
if length(stats) < 2
    return
end

% Find the n largest CCs
cellStats = struct2cell(stats);
areas = cell2mat(cellStats(1, :));
[~, sortInds] = sort(areas, 'descend');
largestCCInds = sortInds(1 : n);

% Re-write the mask with just this CC
mask = false(size(mask));
for ccIdx = largestCCInds
    mask(stats(ccIdx).PixelIdxList) = true;
end

end