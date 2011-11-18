function out = gradface(I, h, sigma)
if nargin < 3
    sigma = 0.5;
end
if nargin < 2
    h = 3;
end

G = fspecial('gaussian', h, sigma);
[Gx, Gy] = gradient(G);
I = imfilter(I, G, 'replicate');
Ix = imfilter(I, Gx, 'replicate');
Iy = imfilter(I, Gy, 'replicate');
out = atan2(Iy, Ix);
out = out(:)';
