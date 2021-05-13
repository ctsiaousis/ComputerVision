%% Set-up
clc; close all; clear all;
I = im2double(rgb2gray(imread('../data/fishes.jpg')));

s = 3 % Lowe: "number of scales per octave at which the image function is
      % sampled prior to extrema detection" "We choose to divide each octave
      %of scale space into an integer number, s, of intervals"
k = 2^(1/s)
num_of_octaves = 3
log_scales_per_octave = s+2 % s+3 gaussian scales => s+2 LoG scales
n = num_of_octaves * log_scales_per_octave % number of levels in scale space
sigma = 1.6; % value recommended by Lowe

VIS = false;


%% create (laplacian of gaussian) filters
% for different values of sigma: sigma, k*sigma, k^2*sigma, ...
fprintf('Generating LoG filters with visualization: %d\n', VIS) %octave
tic
log_filters = generateLoGfilters(log_scales_per_octave, k, sigma, VIS);
toc

%% Generate scale-space
fprintf('Generating scale space with visualization: %d\n', VIS) %octave
tic
scale_space = generateScaleSpace( I, num_of_octaves, ...
    log_scales_per_octave, log_filters, sigma, VIS);
toc


%% Local Extrema Detection
fprintf('Performing Local Extrema Detection\n')
tic
extrema = generateExtrema(num_of_octaves, ...
    log_scales_per_octave, scale_space, s);
toc

%% Display the results for each octave
fprintf('Displaying blobs\n')
tic
figure
figCount = 1;
for i=1:num_of_octaves
    for sc=2:log_scales_per_octave-1
        % find nonzero elements
        [cx, cy] = find(extrema{i}(:,:,sc-1));
        % allocate subplot slot
        subplot(log_scales_per_octave-2,num_of_octaves,figCount)
        figCount = figCount + 1;
        assert(~isempty(cx) && ~isempty(cy), 'Could not find non-zeros')
        % display blobs
        radii = k^(-sc) * sigma * ones(size(cy));
        show_all_circles(imresize(I, 1/i, 'bilinear'), cx, cy, radii)
    end
end
toc

return
