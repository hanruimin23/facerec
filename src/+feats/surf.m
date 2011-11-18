function out = surf(I, blkSize, surfSize)
if nargin < 3
    surfSize = 64;
end

[m, n] = size(I);
s0 = (blkSize + 1) / 2;
[X, Y] = meshgrid(s0:blkSize:n, s0:blkSize:m);
out = extractFeatures(I, [X(:), Y(:)], 'Method', 'SURF', 'SURFSize', surfSize);
out = out(:)';
