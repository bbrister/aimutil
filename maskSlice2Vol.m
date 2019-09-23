function maskVol = maskSlice2Vol(maskSlice, imVol, imSlice)
%MASKSLICE2VOL given an image volume, an axial slice and its corresponding
%mask, convert the mask into a full volume.

z = sliceGetZ(slice, im);
maskVol = false(size(im));
maskVol(:, :, z) = mask';

end