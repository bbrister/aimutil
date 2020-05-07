function im = maskedSepFilter3D(im, mask, kx, ky, kz)
% Apply a separable filter kernel in 3D, ignoring pixels not in 'mask', and
% scaling the kernel accordingly. 
%
% Question: How to scale? Naive way is ones(size(kx)), etc. However, this
% doesn't take into account weighted averages like Gaussian. One answer is
% to scale with abs(kx), which gives the L_inf operator norm.
%
% Math question: is this a linear operator on the domain defined by 'mask'?
% Answer: Yes! (But not on R^n)

% Apply the mask
im(~mask) = 0;

% Apply the filter to the masked image
im = sepFilter3D(im, kx, ky, kz);

% Get the scaling factor, the L_inf operator norm (formerly 'counts')
% Note: maskedFftFiltN has the ability to specify the normalization kernel,
% but we don't need this for non-negative filters.
normalizer = sepFilter3D(double(mask), abs(kx), abs(ky), abs(kz));

% Scale and mask the output
im = (im ./ normalizer) .* mask;

end