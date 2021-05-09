clc; close all; clear all;
I = im2double(rgb2gray(imread('../data/fishes.jpg')));

s = 2 % Lowe: "number of scales per octave at which the image function is sampled prior to extrema detection" "We choose to divide each octave of scale space into an integer number, s, of intervals"
k = 2^(1/s)
num_of_octaves = 3
log_scales_per_octave = s+2 % s+3 gaussian scales => s+2 LoG scales
n = num_of_octaves * log_scales_per_octave % number of levels in scale space
sigma = 1.6; % value recommended by Lowe

% create laplacian of gaussian filters for different values of sigma: sigma, k*sigma, k^2*sigma, ...
figure
log_filters = cell(log_scales_per_octave, 1);
for i = 1:log_scales_per_octave
    k_power = i-1;
    sigma_prime = k^k_power * sigma;
    % D(x,y,σ) = (G(x,y,kσ)-G(x,y,σ))∗I(x,y) "the difference between the [Gaussian] images at scales κσ and σ is attributed a blur level σ"
    log_filters{i} = (k - 1) * sigma_prime^2 * fspecial('log', floor(4*sigma_prime) * 2 + 1, sigma_prime);
    subplot(1, log_scales_per_octave, i)
    mesh(log_filters{i});
end

scale_space = cell(num_of_octaves, log_scales_per_octave);

% Lowe: "We double the size of the input image using linear interpolation prior to building the first level of the pyramid"
figure
figCount = 1;
I2 = imresize(I, 2, 'bilinear');
for o = 1:num_of_octaves
    for i = 1:log_scales_per_octave
        scale_space{o, i} = imfilter(I2, log_filters{i}, 'same', 'conv');
        subplot(num_of_octaves, log_scales_per_octave, figCount)
        imshow(scale_space{o, i}, []);
        figCount = figCount+1;
    end
    % Lowe: "Once a complete octave has been processed, we resample the Gaussian image that has twice the initial value of \sigma by taking every second pixel in each row and column"
    I2 = reduce(I2, 2*sigma);
end

% Local Extrema Detection
extrema = cell(num_of_octaves, 1);
for o = 1:num_of_octaves
    extrema{o} = zeros(size(scale_space{o, i}, 1), size(scale_space{o, i}, 2), s);
    for i = 2:log_scales_per_octave-1
        for x = 2:size(scale_space{o, i}, 1)-2
            for y = 2:size(scale_space{o, i}, 2)-2
                neighbors = scale_space{o, i}(x-1:x+1, y-1:y+1)(:);
                neighbors(5) = [];
                % neighbors now contains 8 neighbors from the current layer
                % we have to add 9 neighbors from the previous layer, and 9 neighbors from the next layer
                neighbors = vertcat(neighbors, scale_space{o, i-1}(x-1:x+1, y-1:y+1)(:), scale_space{o, i+1}(x-1:x+1, y-1:y+1)(:));
                % we now have 26 neighbors
                sample_point = scale_space{o, i}(x, y);
                % compare each sample point with its 26 neighbors
                % select it if it's larger than all of these neighbors or smaller than all of them
                if sample_point > max(neighbors) || sample_point < min(neighbors)
                    extrema{o}(x, y, i) = 1;
                end
            end
        end
    end
end

close();