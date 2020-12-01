function [gx, gy, gz] = gaussFilterKernel3D(sigmas, n, units)
% Return a 3D Gaussian filter kernel

if nargin < 3 || isempty(units)
    units = [1 1 1];
elseif isscalar(units)
    units = repmat(units, [1 3]);
end

% Convert scalar sigmas to units, if provided
if isscalar(sigmas)
    sigmas = sigmas ./ units;
end

if nargin < 2 || isempty(n)
    halfWidths = ceil(3 * sigmas);
    widths = 2 * halfWidths + 1;
else
    widths = repmat(n, [1 3]);
end

gx = fspecial('gauss', [widths(1) 1], sigmas(1) + eps);
gy = fspecial('gauss', [1 widths(2)], sigmas(2) + eps);
gz = permute(fspecial('gauss', [widths(3) 1], sigmas(3) + eps), [3 2 1]);

end