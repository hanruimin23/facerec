function out = minkowski(p)
out = @(u, v) -(sum(abs(u - v) .^ p) .^ (1 / p));
