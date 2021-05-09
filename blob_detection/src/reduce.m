function [out] = reduce(I, sigma)
    % create gaussian filter
    K = fspecial('gaussian', floor(4*sigma) * 2 + 1, sigma);
    % convolve image with filter
    Ifiltered = imfilter(I, K, 'same', 'conv');
    % downsample
    out = Ifiltered(1:2:end, 1:2:end);
end
