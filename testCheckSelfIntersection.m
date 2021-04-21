% Script to test checkSelfIntersection.m

% Self-intersecting polygon: (0,0), (0,1), (1,0), (-1,1)
X = [0 0 1 -1]';
Y = [0 1 0 1]';

assert(checkSelfIntersection(X, Y))

% Collinear polygon (x axis)
X = (1 : 4)';
Y = zeros(size(X));
assert(checkSelfIntersection(X, Y))

% Non-intersecting polygon (square)
X = [0 0 1 1]';
Y = [0 1 1 0]';
assert(~checkSelfIntersection(X, Y))

% Test non-intersecting polygon (triangle)
X = [0 0 1]';
Y = [0 1 0]';
assert(~checkSelfIntersection(X, Y))

disp('Tests passed!')