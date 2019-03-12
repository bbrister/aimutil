function [vol, units] = dcmStackImages(filenames)
% Fallback image reading which stacks the images by their instance numbers

% Read the instance numbers
numSlices = length(filenames);
instanceNums = zeros([numSlices 1]);
for i = 1 : numSlices
    name = filenames{i};
    info = dicominfo(name);
    instanceNums(i) = info.InstanceNumber;
end

% Get the sorting order
[~, order] = sort(instanceNums, 'ascend');

% Read the volume
for i = 1 : numSlices
   name = filenames{order(i)};
   [slice, units] = imRead3D(name);
   slice = squeeze(slice);
   units = [min(units) min(units) max(units)];
   assert(size(slice, 3) == 1)
   if i == 1
       volSiz = [size(slice, 1) size(slice, 2) numSlices size(slice, 3)];
       vol = zeros(volSiz);
   end
   vol(:, :, i) = slice;
end

end