function stats = evalPairMatcher(pairs, scoreFun)
scores = utils.computeScores(pairs(:, 1), pairs(:, 2), scoreFun);
stats = utils.Stats(scores, cell2mat(pairs(:, 3)));
