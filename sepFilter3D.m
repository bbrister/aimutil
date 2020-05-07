function im = sepFilter3D(im, kx, ky, kz)
% Apply a separable filter kernel to a 3D image

im = imfilter(imfilter(imfilter(im, kx), ky), kz);

end