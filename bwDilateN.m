function y = bwDilateN(x, k, extrapVal)
% Dilate a binary image x by the structuring kernel k. Works in N-D using
% FFTs for speed. Assumes that both x and k are binary images. k can also
% be a structuring element.

if nargin < 3
    extrapVal = [];
end

% Convert structuring elements
try
    k = k.getnhood;
catch
end

y = fftFiltN(x, k, extrapVal) > 1e-2;

end