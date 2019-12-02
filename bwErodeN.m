function y = bwErodeN(x, k)
% Like bwDilateN, but performs erosion using DeMorgan's Law. k is either an
% array or a structuring element

y = ~bwDilateN(~x, k, 1);

end