function y = bwErodeN(x, k)
% Like bwDilateN, but performs morphological erosion.
    y = ~bwDilateN(~x, k);
end