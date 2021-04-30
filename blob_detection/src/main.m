I = im2double(rgb2gray(imread('../data/fishes.jpg')));

s = 2 % Lowe: "number of scales per octave at which the image function is sampled prior to extrema detection" "We choose to divide each octave of scale space into an integer number, s, of intervals"
k = 2^(1/s)
num_of_octaves = 3
log_scales_per_octave = s+2 % s+3 gaussian scales => s+2 LoG scales
n = num_of_octaves * log_scales_per_octave % number of levels in scale space
sigma = 1.6; % value recommended by Lowe

% create laplacian of gaussian filters for different values of sigma: sigma, k*sigma, k^2*sigma, ...
log_filters = cell(log_scales_per_octave, 1);
for i = 1:log_scales_per_octave
    k_power = i-1;
    sigma_prime = k^k_power * sigma;
    % D(x,y,σ) = (G(x,y,kσ)-G(x,y,σ))∗I(x,y) "the difference between the [Gaussian] images at scales κσ and σ is attributed a blur level σ"
    log_filters{i} = (k - 1) * sigma_prime^2 * fspecial('log', floor(4*sigma_prime) * 2 + 1, sigma_prime);
    figure, mesh(log_filters{i});
end

scale_space = cell(num_of_octaves, log_scales_per_octave);

% Lowe: "We double the size of the input image using linear interpolation prior to building the first level of the pyramid"
I2 = imresize(I, 2, 'bilinear');
for o = 1:num_of_octaves
    for i = 1:log_scales_per_octave
        scale_space{o, i} = imfilter(I2, log_filters{i}, 'same', 'conv');
        figure, imshow(scale_space{o, i}, []);
    end
    % Lowe: "Once a complete octave has been processed, we resample the Gaussian image that has twice the initial value of \sigma by taking every second pixel in each row and column"
    I2 = reduce(I2, 2*sigma);
end
