function out = preprocess(I, m, n, downsamplingFactor)
[M, N, P] = size(I);
if P == 3
    I = rgb2gray(I);
end

y0 = floor((M - m) / 2);
y1 = y0 + m - 1;
x0 = floor((N - n) / 2);
x1 = x0 + n - 1;

out = im2double(I(y0:y1, x0:x1));
out = imresize(out, downsamplingFactor);
