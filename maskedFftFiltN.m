function Xfilt = maskedFftFiltN(X, mask, k, kNorm)
% Like maskedSepFilter3D, but with ffts. Computes the linear convolution,
% not the circular convolution, by padding X with zeros. This function then
% removes the padding from the output.
%
% kNorm is the normalization kernel. Defaults to abs(k), the L_inf operator
% norm.

if nargin < 4 || isempty(kNorm)
    kNorm = abs(k);
end

% Apply the mask
X(~mask) = 0;

% Filter with FFTs, normalizing by kNorm
Xfilt = fftFiltN(X, k);
normalizer = fftFiltN(single(mask), single(kNorm));

% % We need to pad the end of X with zeros, to compute linear convolution
% % from circular convolution
% fftSiz = size(X) + size(k) - 1;
% 
% % Take the Fourier transforms of the inputs
% Xf = fftn(X, fftSiz);
% kf = fftn(k, fftSiz);
% maskf = fftn(single(mask), fftSiz);
% countf = fftn(single(ones(size(k))), fftSiz);
% 
% % Apply the filters
% Xfilt = ifftn(Xf .* kf, 'symmetric');
% counts = ifftn(maskf .* countf, 'symmetric');
% 
% % Remove the padding at the beginning
% Xfilt = unpad(Xfilt, size(X));
% counts = unpad(counts, size(X));

% The minimum possible value is min(kNorm(:))
minVal = min(kNorm(:));

% Scale
Xfilt = Xfilt * numel(k) ./ max(normalizer, minVal);

% Mask the output
Xfilt(~mask) = 0;

end

% Remove zero-padding, by taking only up to siz elements from x
function x = unpad(x, siz)

% Form an expression and 'eval'
expr = 'x = x(';
for k = 1 : length(siz)
    expr = [expr '1 : ' num2str(siz(k))];
    if k < length(siz)
        expr = [expr ', '];
    end
end
expr = [expr ');'];

eval(expr)
end

function B = insertArray(A, B, lo, hi)
% B(lo(1) : hi(1) , lo(2) : hi(2), ...) = A
subs = cell(5, length(lo));
[subs{:}] = ind2sub(size(A), 1 : numel(A));
idx = sub2ind(size(B), subs{:});
B(idx) = A;
end

function B = subArray(A, lo, hi)
% B = A(lo(1) : hi(1) , lo(2) : hi(2), ...)

% Form an expression and 'eval'
expr = 'B = A(';
for k = 1 : length(lo)
    expr = [expr num2str(lo(k)) ' : ' num2str(hi(k))];
    if k < length(lo)
        expr = [expr ', '];
    end
end
expr = [expr ');'];

eval(expr)
end

function X = circshiftn(X, amt)
% circshift in each dimension

for k = 1 : length(amt)
   X = circshift(X, amt(k), k);
end

end