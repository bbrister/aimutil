function [im, kernel] = imGaussFilter3D(im, sigmas, n, units)
% Get a 3D gaussian filter kernel of width n. Optionally adjust to the
% units, in which case sigma is given in mm. Also returns the filter kernel

if nargin < 2
    sigmas = [];
end
if nargin < 3
    n = [];
end
if nargin < 4
    units = [];
end

[gx, gy, gz] = gaussFilterKernel3D(sigmas, n, units);

im = sepFilter3D(im, gx, gy, gz);
kernel = convn(convn(gx, gy, 'full'), gz, 'full');

end