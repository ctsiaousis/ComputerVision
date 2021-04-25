I = im2double(rgb2gray(imread('../data/fishes.jpg')));

num_of_octaves = 4;
scales_per_octave = 3; % value recommended by Lowe
n = num_of_octaves * scales_per_octave; % numbers of levels in scale space
sigma = 1.6; % value recommended by Lowe
k = sqrt(2); % value recommended by Lowe

% create laplacian of gaussian filters for different values of sigma: sigma, k*sigma, k^2*sigma, ...
log_filters = cell(scales_per_octave, 1);
for i = 1:scales_per_octave
    k_power = i-1;
    sigma_prime = k^k_power * sigma;
    log_filters{i} = ((k - 1) * sigma_prime^2) * fspecial('log', floor(4*sigma_prime) * 2 + 1, sigma_prime);
    figure, mesh(log_filters{i});
end

scale_space = cell(n, 1);

% Lowe: "We double the size of the input image using linear inter-polation prior to building the first level of the pyramid"
I2 = imresize(I, 2, 'bilinear');
for i = 1:num_of_octaves
    for j = 1:scales_per_octave
        index = (i-1)*scales_per_octave + j;
        scale_space{index} = imfilter(I2, log_filters{j}, 'same', 'conv');
        figure, imshow(scale_space{index}, []);
    end
    % downsample the 3rd image of this octave because the 3rd image has sigma_prime = k^2*sigma = 2*sigma
    % Lowe: "Once a complete octave has been processed, we resample the Gaussian image that has twice the initial value of \sigma"
    I2 = scale_space{(i-1)*scales_per_octave + 3}(2:2:end, 2:2:end);
end
