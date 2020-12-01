function mask = largestCC(mask)
% Take the largest connected component of a  binary mask

stats =  regionprops(mask, 'Area', 'PixelIdxList');
if length(stats) < 2
    return
end

% Find the largest CC
cellStats = struct2cell(stats);
areas = cell2mat(cellStats(1, :));
[~, maxIdx] = max(areas);

% Re-write the mask with just this CC
mask = false(size(mask));
mask(stats(maxIdx).PixelIdxList) = true;

end