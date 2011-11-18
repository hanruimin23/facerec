function dataset = loadV2Restricted(variant, featFun)
lfwPath = 'datasets/lfw';

dataset = datasets.PairsDataset([lfwPath, '/', variant], featFun, 'jpg');

pairsFid = fopen([lfwPath, '/pairs.txt'], 'r');
nFolds = fscanf(pairsFid, '%d', 1);
nPosPairsByFold = fscanf(pairsFid, '%d', 1);

for idx = 1:nFolds
    posPairs = textscan(pairsFid, '%s %d %d', nPosPairsByFold);
    % nPosPairsByFold == nNegPairsByFold for lfw
    negPairs = textscan(pairsFid, '%s %d %s %d', nPosPairsByFold);

    dataset.loadPairs(posPairs, negPairs);
end

fclose(pairsFid);
