% Before trying to construct hybrid images, it is suggested that you
% implement my_imfilter.m and then debug it using assigment1_filtering_test.m

% Debugging tip: You can split your MATLAB code into cells using "%%"
% comments. The cell containing the cursor has a light yellow background,
% and you can press Ctrl+Enter to run just the code in that cell. This is
% useful when projects get more complex and slow to rerun from scratch

close all; % closes all figures

%% Setup
% read images and convert to floating point format
image1 = im2single(imread('../data/pair2_joker.png'));
image2 = im2single(imread('../data/pair2_HeathLedger.png'));

% Several additional test cases are provided for you, but feel free to make
% your own (you'll need to align the images in a photo editor such as
% Photoshop). The hybrid images will differ depending on which image you
% assign as image1 (which will provide the low frequencies) and which image
% you asign as image2 (which will provide the high frequencies)

%% Filtering and Hybrid Image construction
% the cutoff frequency (half power point) in cycles/image
cutoff_frequency1 = 5
% the standard deviation in the frequency domain.
% divide by 1.1774 because the cutoff frequency is the half power point
sigma_freq1 = cutoff_frequency1 / 1.1774
N1 = size(image1)(1)
% the standard deviation, in pixels, of the Gaussian blur
% derived from the formula sigma * sigma_freq = N / (2*pi)
sigma1 = N1/(2*pi*sigma_freq1)
filter1 = fspecial('Gaussian', floor(sigma1*2)*2+1, sigma1);

cutoff_frequency2 = 12
sigma_freq2 = cutoff_frequency2 / 1.1774
N2 = size(image2)(1)
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
figure(1); imshow(low_frequencies)
figure(2); imshow(high_frequencies + 0.5);
vis = visualize_hybrid_image(hybrid_image);
figure(3); imshow(vis);
imwrite(low_frequencies, 'low_frequencies.jpg', 'quality', 95);
imwrite(high_frequencies + 0.5, 'high_frequencies.jpg', 'quality', 95);
imwrite(hybrid_image, 'hybrid_image.jpg', 'quality', 95);
imwrite(vis, 'hybrid_image_scales.jpg', 'quality', 95);
