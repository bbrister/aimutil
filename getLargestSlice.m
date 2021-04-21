function slice = getLargestSlice(mask)
    slice = mask(:, :, largestSliceIdx(mask));
end