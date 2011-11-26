function out = minkowski(p)
out = @(u, v) -norm(u - v, p);
