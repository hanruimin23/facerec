function out = lbp(I, blkSize, radius)
persistent lbpMapping

if isempty(lbpMapping)
    lbpMapping = lbp.getmapping(8, 'u2');
end

if nargin < 3
    radius = 1;
end

out = blockproc(I, [blkSize, blkSize], @(blkStruct) lbp.lbp(blkStruct.data, ...
    radius, 8, lbpMapping, 'nh'), 'PadPartialBlocks', true);
out = out(:)';
