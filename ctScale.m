function im = ctScale(im)
% Blaine Rister scale CT images to improve contrast

% Convert to double
im = double(im);

% Translate so minimum value is 0
im = im - min(im(:));

% Translate again so that the minimum in-scan value is 0
im = im - min(im(im > 0));

% Clip negative values
im(im < 0) = 0;

% Scale
im = im / max(im(:));

end