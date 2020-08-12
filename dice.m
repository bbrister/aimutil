function score = dice(X, Y, numClasses)
% Compute the dice score between two arrays

% Verify inputs
maxClass = numClasses - 1;
assert(all(X(:) <= maxClass))
assert(all(Y(:) <= maxClass))
assert(numel(X) == numel(Y))

score = zeros(numClasses, 1);
for i = 1 : numClasses
    class = i - 1;
    Xclass = X(:) == class;
    Yclass = Y(:) == class;
    score(i) = 2 * sum(Xclass & Yclass) / (sum(Xclass) + sum(Yclass));
end

end