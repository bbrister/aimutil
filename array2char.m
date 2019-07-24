function [Xenc, offset, scale] = array2char(X)
% Converts an array to a string. Each element of 'Xenc' corresponds to a 
% row of X. The offset and scale are used to map X to the range [0, 65535].

% Offset
offset = min(X(:));
X = X - offset;

% Scaling
scale = 65535 / max(X(:));
X = X * scale;

% Convertsion
Xenc = char(X);

end