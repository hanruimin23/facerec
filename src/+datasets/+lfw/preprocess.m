function out = preprocess(I, faceSize, downsamplingFactor)
[M, N, P] = size(I);
if P == 3
    I = rgb2gray(I);
end

y0 = floor((M - faceSize(1)) / 2);
y1 = y0 + faceSize(1) - 1;
x0 = floor((N - faceSize(2)) / 2);
x1 = x0 + faceSize(2) - 1;
out = imadjust(wiener2(im2double(I(y0:y1, x0:x1))));
out = imresize(out, downsamplingFactor);
