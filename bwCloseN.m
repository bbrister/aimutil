function y = bwCloseN(x, k)
% N-dimensional morphological closing, via FFTs
    y = bwErodeN(bwDilateN(x, k), k);
end