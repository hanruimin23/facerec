function dataset = loadV1Restricted(variant, featFun)
lfwPath = 'datasets/lfw';

dataset = datasets.PairsDataset([lfwPath, '/', variant], featFun, 'jpg');

[posPairs, negPairs] = getPairsFromFile(lfwPath, 'pairsDevTest.txt');
dataset.loadPairs(posPairs, negPairs);

[posPairs, negPairs] = getPairsFromFile(lfwPath, 'pairsDevTrain.txt');
dataset.loadPairs(posPairs, negPairs);

function [posPairs, negPairs] = getPairsFromFile(lfwPath, pairsFilename)
pairsFid = fopen([lfwPath, '/', pairsFilename], 'r');
nPosPairs = fscanf(pairsFid, '%d', 1);
posPairs = textscan(pairsFid, '%s %d %d', nPosPairs);
% nPosPairs == nNegPairs for lfw
negPairs = textscan(pairsFid, '%s %d %s %d', nPosPairs);
fclose(pairsFid);
