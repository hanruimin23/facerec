function out = wavelet(I, wname, level)
if nargin < 3
    level = 3;
end

[C, S] = wavedec2(I, level, wname);
out = C(1:prod(S(1, :)));
