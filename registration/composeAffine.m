function C = composeAffine(A, B)
% Compute the affine transform A \circ B, where each is an [n x n + 1]
% matrix

% Check input dimensions
siz = size(A);
n = siz(1);
assert(isequal(siz, size(B)));
assert(isequal(siz, [n n+1]));

% Compute the composed affine transform
C = zeros(siz);
C(1:3, 1:3) = A(1:3, 1:3) * B(1:3, 1:3);
C(:, 4) = A(1:3, 1:3) * B(:, 4) + A(:, 4);

end