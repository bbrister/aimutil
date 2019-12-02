function y = bwOpenN(x, k)
% N-dimensional morphological closing, via FFTs
    y = bwDilateN(bwErodeN(x, k), k);
end