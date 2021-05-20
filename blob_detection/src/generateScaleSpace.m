function scale_space = generateScaleSpace(IMAGE, ...
    num_of_octaves, log_scales_per_octave, log_filters, k, sigma, ...
    isEfficient, boolVis)
  scale_space = cell(num_of_octaves, log_scales_per_octave);
  % Lowe: "We double the size of the input image using linear
  % interpolation prior to building the first level of the pyramid"
  if boolVis %only for visualization
    figure
    figCount = 1;
  end
  I2 = imresize(IMAGE, 2, 'bilinear');
  for o = 1:num_of_octaves
      for i = 1:log_scales_per_octave
          % filter the image of the octave with 
          % its corresponding log_filter
          if ~isEfficient
            scale_space{o, i} = imfilter(I2 , log_filters{i}, 'same', 'conv');
            %size(scale_space{o, i})
          else
            scale_space{o, i} = imresize(imfilter(imresize(I2, 1/k^(i-1), 'bilinear') , log_filters{1}, 'same', 'conv'), k^(i-1), 'bilinear');
            %size(scale_space{o, i})
          end
          if boolVis %only for visualization
              subplot(num_of_octaves, log_scales_per_octave, figCount)
              imagesc(scale_space{o, i}); colormap gray; colorbar;
              figCount = figCount+1;
          end
      end
      % Lowe: "Once a complete octave has been processed, we resample
      % the Gaussian image that has twice the initial value of \sigma
      % by taking every second pixel in each row and column"
      I2 = reduce(I2, 2*sigma);
  end
end
