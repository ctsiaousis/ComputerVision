% Before trying to construct hybrid images, it is suggested that you
% implement my_imfilter.m and then debug it using assigment1_filtering_test.m

% Debugging tip: You can split your MATLAB code into cells using "%%"
% comments. The cell containing the cursor has a light yellow background,
% and you can press Ctrl+Enter to run just the code in that cell. This is
% useful when projects get more complex and slow to rerun from scratch

close all; % closes all figures

%% Setup
% read images and convert to floating point format
input_dir = '../data/';
%files = {'pair1_marilyn.bmp', 'pair1_einstein.bmp'}
files = {'pair2_joker.png', 'pair2_HeathLedger.png'};
image1 = im2single(imread(strcat(input_dir, files{1})));
image2 = im2single(imread(strcat(input_dir, files{2})));

% Several additional test cases are provided for you, but feel free to make
% your own (you'll need to align the images in a photo editor such as
% Photoshop). The hybrid images will differ depending on which image you
% assign as image1 (which will provide the low frequencies) and which image
% you asign as image2 (which will provide the high frequencies)

% plot images in the frequency domain
figure, imagesc(log(abs(fftshift(fft2(rgb2gray(image1))))));
figure, imagesc(log(abs(fftshift(fft2(rgb2gray(image2))))));

%% Filtering and Hybrid Image construction
% the cutoff frequency (half amplitude point) in cycles/image
cutoff_frequency_avg = 11
gap = 0.2

cutoff_frequency1 = cutoff_frequency_avg * (1-gap)
% calculate the standard deviation in the frequency domain
% using the formula: \sigma_f = f_c / \sqrt{2\ln(c)}
% for c = 2 because the cutoff frequency is the half amplitude point
sigma_freq1 = cutoff_frequency1 / sqrt(2*log(2))
N1 = size(image1, 1)
% the standard deviation, in pixels, of the Gaussian blur
% derived from the formula sigma * sigma_freq = N / (2*pi)
sigma1 = N1/(2*pi*sigma_freq1)
filter1 = fspecial('Gaussian', floor(sigma1*2)*2+1, sigma1);

cutoff_frequency2 = cutoff_frequency_avg * (1+gap)
sigma_freq2 = cutoff_frequency2 / sqrt(2*log(2))
N2 = size(image2, 1)
sigma2 = N2/(2*pi*sigma_freq2)
filter2 = fspecial('Gaussian', floor(sigma2*2)*2+1, sigma2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE BELOW. Use my_imfilter to create 'low_frequencies' and
% 'high_frequencies' and then combine them to create 'hybrid_image'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove the high frequencies from image1 by blurring it. The amount of
% blur that works best will vary with different image pairs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

low_frequencies = my_imfilter(image1, filter1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove the low frequencies from image2. The easiest way to do this is to
% subtract a blurred version of image2 from the original version of image2.
% This will give you an image centered at zero with negative values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

blur2 = my_imfilter(image2, filter2);
high_frequencies = image2 - blur2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine the high frequencies and low frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hybrid_image = high_frequencies + low_frequencies;
% hybrid_image = im2double(hybrid_image);

%% Visualize and save outputs
figure; imshow(low_frequencies)
figure; imshow(high_frequencies + 0.5);
vis = visualize_hybrid_image(hybrid_image);
figure; imshow(vis);
% save files
output_dir='./';
output_format=strcat(output_dir, files{1}, '__', files{2}, '__%s__', 'fc', num2str(cutoff_frequency_avg), '_g', num2str(100*gap), '.jpg');
imwrite(low_frequencies, sprintf(output_format, 'low_frequencies'), 'quality', 95);
imwrite(high_frequencies + 0.5, sprintf(output_format, 'high_frequencies'), 'quality', 95);
imwrite(hybrid_image, sprintf(output_format, 'hybrid_image'), 'quality', 95);
imwrite(vis, sprintf(output_format, 'hybrid_image_scales'), 'quality', 95);
