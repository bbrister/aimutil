function y = fftFiltN(x, k, extrapVal)
%y = fftFiltN(x, k). Computes y = x * k, with zero-padding, and trims the 
% output so that x is the same size as y. x and k can be n-dimensional.
% Uses Fourier transforms for efficient computation.
% extrapVal is the value used to extrapolate x beyond the image boundaries.
% k is always extrapolated with 0.

if nargin < 3 || isempty(extrapVal)
    extrapVal = 0;
end

% Ensure that k has even dimensions, if not give a warning
odd = mod(size(k), 2) == 1;
if ~all(odd)
   warning('k has even dimensions, output crop is ambiguous')
end

% We need to pad the end of x with zeros, to compute linear convolution
% from circular convolution
fftSiz = zeros(size(size(x)));
for j = 1 : length(fftSiz) % Loop needed for trailing dimensions
   fftSiz(j) = size(x, j) + size(k, j) - 1;
end


% Compute the half-width of k, accounting for trailing dimensions
halfWidth = zeros(size(fftSiz));
for j = 1 : length(fftSiz)
    halfWidth(j) = floor(size(k, j) / 2);
end

% Take the Fourier transforms of the inputs
xf = fftn(pad(x, fftSiz, extrapVal));
kf = fftn(pad(k, fftSiz, 0));

% Apply the filters
y = ifftn(xf .* kf, 'symmetric');

% Remove the padding at the beginning
y = unpad(y, size(x), halfWidth);

end

% Add padding with the given extrapVal
function y = pad(x, siz, extrapVal)

% Get the base array for y
y = ones(siz) * extrapVal;

% Form an expression and 'eval', to insert x in
expr = 'y(';
for k = 1 : length(siz)
    expr = [expr '1 : ' num2str(size(x, k))];
    if k < length(siz)
        expr = [expr ', '];
    end
end
expr = [expr ') = x;'];

eval(expr)

end

% Remove zero-padding, by taking only up to siz elements from x
function y = unpad(y, siz, shift)

% Form an expression and 'eval'
expr = 'y = y(';
for k = 1 : length(siz)
    dimShift = shift(k);
    expr = [expr num2str(1 + dimShift) ' : ' num2str(siz(k) + dimShift)];
    if k < length(siz)
        expr = [expr ', '];
    end
end
expr = [expr ');'];

eval(expr)
end