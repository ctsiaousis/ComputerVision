function [mag,ori] = mygradient(I)
%
% compute image gradient magnitude and orientation at each pixel
%
%
assert(ndims(I)==2,'input image should be grayscale');

% central difference
F = 0.5 .* [-1 0 1];
% prewitt
%F = (1/3) .* [-1 0 1; -1 0 1; -1 0 1];
% sobel
%F = (1/8) .* [1   0  -1;...
%              2   0  -2;...
%              1   0  -1]

dx = imfilter(I, F, 'replicate');
dy = imfilter(I, F', 'replicate');

mag = sqrt(dx.^2 + dy.^2);
ori = atan2(-dy, dx); % -dy gives us the same orientation as imgradient

assert(all(size(mag)==size(I)),'gradient magnitudes should be same size as input image');
assert(all(size(ori)==size(I)),'gradient orientations should be same size as input image');

% figure, imagesc(mag), title('magnitude');
% figure, imagesc(ori), title('orientation');

% % compare result with imgradient
% [mag2, ori2] = imgradient(I, 'central');
% %[mag2, ori2] = imgradient(I, 'prewitt');
% %[mag2, ori2] = imgradient(I, 'sobel');
% immse(mag, mag2)
% figure, imagesc(mag2);
% figure, imagesc(ori2);
