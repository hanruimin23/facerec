function dataset = loadV2Restricted(variant, featFun)
lfwPath = 'datasets/lfw';

dataset = datasets.PairsDataset([lfwPath, '/', variant], featFun, 'jpg');

pairsFid = fopen([lfwPath, '/pairs.txt'], 'r');
nFolds = fscanf(pairsFid, '%d', 1);
nPosPairsByFold = fscanf(pairsFid, '%d', 1);

totalProgressBarMsg = 'Loading fold %d/%d...';
hTotalProgressBar = waitbar(0, sprintf(totalProgressBarMsg, 1, nFolds), ...
    'Name', ['Loading LFW View 2 (', variant, ') dataset']);
hFoldProgressBar = waitbar(0, '', 'Name', 'Fold progress');

for idx = 1:nFolds
    posPairs = textscan(pairsFid, '%s %d %d', nPosPairsByFold);
    % nPosPairsByFold == nNegPairsByFold for lfw
    negPairs = textscan(pairsFid, '%s %d %s %d', nPosPairsByFold);

    dataset.loadPairs(posPairs, negPairs, true, hFoldProgressBar);

    waitbar(idx / nFolds, hTotalProgressBar, sprintf(totalProgressBarMsg, ...
        min(idx + 1, nFolds), nFolds));
end

fclose(pairsFid);

close(hFoldProgressBar);
close(hTotalProgressBar);
