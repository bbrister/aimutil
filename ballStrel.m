function s = ballStrel(n, diam, units)
% Get an n-dimensional ball-shaped 'strel' for morphology. diam is in
% physical coordinates given by 'units'.

if nargin < 3 || isempty(units)
    units = ones(1, n);
elseif ~isrow(units)
    units = units';
end

% Get the size
radius = (diam - 1) / 2;
siz = ceil(diam ./ units);

% Get a 3D ball
center = 1 + (siz - 1) / 2;
mask = ballMask(siz, center, diam / 2, units);

s = strel(mask);

end