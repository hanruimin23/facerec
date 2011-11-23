function out = lbp(I, blkSize, radius)
persistent lbpMapping

if isempty(lbpMapping)
    lbpMapping = lbp.getmapping(8, 'u2');
end

if nargin < 3
    radius = 1;
end

[M, N] = size(I);
out = zeros(ceil(M / blkSize(1)) * ceil(N / blkSize(2)), lbpMapping.num);
n = 1;
for y0 = 1:blkSize(1):M
    for x0 = 1:blkSize(2):N
        y1 = min(y0 + blkSize(1) - 1, M);
        x1 = min(x0 + blkSize(2) - 1, N);
        out(n, :) = lbp.lbp(I(y0:y1, x0:x1), radius, 8, lbpMapping, 'h');
        n = n + 1;
    end
end
out = out(:)';
