%% Set-up
clc; close all; clear all;
I = im2double(rgb2gray(imread('../data/plumeria.jpg')));

s = 3 % Lowe: "number of scales per octave at which the image function is
      % sampled prior to extrema detection" "We choose to divide each octave
      %of scale space into an integer number, s, of intervals"
k = 2^(1/s)
num_of_octaves = 3
log_scales_per_octave = s+2 % s+3 gaussian scales => s+2 LoG scales
n = num_of_octaves * log_scales_per_octave % number of levels in scale space
sigma = 1.6; % value recommended by Lowe

threshold = 0.3 % the percentage of rejected matches

VIS = true;

tStart = tic;
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
[extrema, xPoints, yPoints, radii] = generateExtrema(num_of_octaves, ...
    log_scales_per_octave, scale_space, s, threshold);
toc

%% Display the results for each octave
fprintf('Displaying blobs\n')
tic
figure
show_all_circles(I, xPoints, yPoints, radii)
toc
fprintf('Total excecution time is: %.2f seconds.\n',toc(tStart))
return
