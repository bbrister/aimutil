function Ainv = invertAffine(A)
% Inverts an [n x n + 1] affine transform matrix

% Get the dimensions
m = size(A, 1);
n = size(A, 2);
assert(n == m + 1);

% Invert the linear part
Ainv = zeros(size(A));
Ainv(1 : m, 1 : m) = inv(A(1 : m, 1 : m));

% Invert the translation
Ainv(:, n) = -Ainv(1 : m, 1 : m) * A(:, n);

end