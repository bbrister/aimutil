function maxSliceIdx = largestSliceIdx(mask)
%largestSliceIdx(mask) return the index of the largest axial slice
    numSlices = size(mask, 3);
    sliceAreas = zeros(numSlices, 1);
    for z = 1 : numSlices
        sliceAreas(z) = sum(mask(:, :, z), [1 2]);
    end
    
    [~, maxSliceIdx] = max(sliceAreas);
end