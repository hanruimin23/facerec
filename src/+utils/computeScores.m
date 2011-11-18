function scores = computeScores(X, Y, scoreFun)
nPairs = size(X, 1);
scores = zeros(nPairs, 1);
for idx = 1:nPairs
    scores(idx) = scoreFun(X{idx}', Y{idx}');
end
