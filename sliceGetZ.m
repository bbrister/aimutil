function z = sliceGetZ(slice, vol)
%dcmGetZ estimate the z-coordinate of a slice, as an (x, y) plane in
% the volume vol. slice is an [MxN] matrix, and vol is an [MxNxP] array.
% The resulting z-coordinate is 0-indexed

% Verify inputs
assert(ismatrix(slice))
assert(isequal(size(slice), [size(vol, 1) size(vol, 2)]))

% Normalize the slice
normSlice = normalizeSlice(slice);

% Find the slice in this volume
corrMax = -1;
for k = 1 : size(vol, 3)
    
   % Take a slice of vol and normalize
   volSlice = vol(:, :, k);
   normVolSlice = normalizeSlice(volSlice);
   
   % Compute the correlation coefficient
   sliceCorr = dot(normSlice(:), normVolSlice(:));
   
   % Update the best match
   if (sliceCorr > corrMax)
      z = k - 1;
      corrMax = sliceCorr;
   end
end

end

function normSlice = normalizeSlice(slice)
% Normalize a slice to zero mean and unit variance

normSlice = (slice - mean(slice(:))) / std(slice(:));

end