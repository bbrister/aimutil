function imWin = intensityWindow(im, lo, hi)
%intensityWindow(im, window) apply the window to the image

imWin = min(1, max(0, (im - lo) / (hi - lo)));

end