function z = sliceGetZ(slice, vol, stride)
%dcmGetZ estimate the z-coordinate of a slice, as an (x, y) plane in
% the volume vol. slice is an [MxN] matrix, and vol is an [MxNxP] array.
% The resulting z-coordinate is 0-indexed

% By default, only sample every 8th pixel
if nargin < 3 || isempty(stride)
    stride = 8;
end

% Verify inputs
assert(ismatrix(slice))
assert(isequal(size(slice), [size(vol, 1) size(vol, 2)]))

% Normalize the slice
strideVec = 1 : stride : numel(slice);
sliceStrided = slice(strideVec);
sliceData = normalize(sliceStrided);

% Find the slice in this volume
corrMax = -1;
for k = 1 : size(vol, 3)
    
   % Take a slice of vol and normalize
   volSlice = vol(:, :, k);
   volData = normalize(volSlice(strideVec));
   
   % Compute the correlation coefficient
   sliceCorr = dot(sliceData, volData);
   
   % Update the best match
   if (sliceCorr > corrMax)
      z = k - 1;
      corrMax = sliceCorr;
   end
end

end

function normSlice = normalize(slice)
% Normalize the data zero mean and unit variance

dev = std(slice(:));
if dev == 0
    dev = 1;
end

normSlice = (slice - mean(slice(:))) / dev;

end