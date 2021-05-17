function [extrema, rowVector, colVector, radiusVector] = generateExtrema(num_of_octaves, log_scales_per_octave, scale_space, s, threshold)
  extrema = cell(num_of_octaves, 1);
  rowVector = []; colVector = []; radiusVector = [];
  sc = 1; %initialize for taking correct scale_space image
  for o = 1:num_of_octaves
      extrema{o} = zeros(size(scale_space{o, sc}, 1), size(scale_space{o, sc}, 2), s);
      for sc = 2:log_scales_per_octave-1
          % calculate the threshold of the current scale
          scMaxThresh = threshold * max(max(scale_space{o, sc}));
          scMinThresh = threshold * min(min(scale_space{o, sc}));
          for x = 2:size(scale_space{o, sc}, 1)-1
              for y = 2:size(scale_space{o, sc}, 2)-1
                  tmpMid  = scale_space{o, sc}(x-1:x+1, y-1:y+1);
                  neighbors = tmpMid(:);
                  sample_point = neighbors(5);
                  neighbors(5) = [];
                  % neighbors now contains 8 neighbors from the current layer
                  % [optimization] check early for extrema in order to avoid finding all 26 neighbors
                  % provides x2 speedup
                  if sample_point > min(neighbors) && sample_point < max(neighbors)
                      continue
                  end
                  if sample_point >= scMinThresh && sample_point <= scMaxThresh
                      continue
                  end
                  % we have to add 9 neighbors from the previous layer, and 9 neighbors from the next layer
                  tmpLow  = scale_space{o, sc-1}(x-1:x+1, y-1:y+1);
                  tmpHigh = scale_space{o, sc+1}(x-1:x+1, y-1:y+1);
                  neighbors = vertcat(neighbors,tmpLow(:),tmpHigh(:));
                  % we now have 26 neighbors
                  % compare each sample point with its 26 neighbors
                  % select it if it's larger than all of these neighbors or smaller than all of them
                  if sample_point >= max(neighbors) || sample_point <= min(neighbors)
                      % reject unstable extrema with low contrast
                      % Eliminating Edge Responses
                      Dxx = scale_space{o, sc}(x+1, y) - scale_space{o, sc}(x-1, y);
                      Dyy = scale_space{o, sc}(x, y+1) - scale_space{o, sc}(x, y-1);
                      Dxy = scale_space{o, sc}(x-1, y+1) - scale_space{o, sc}(x-1, y-1) - scale_space{o, sc}(x+1, y+1) + scale_space{o, sc}(x+1, y-1);
                      r = 10;
                      H = [Dxx Dxy; Dxy Dyy]; % Hessian matrix
                      if ((trace(H)^2 / det(H)) >= (r+1)^2 / r)
%                           fprintf('extremum rejected\n')
                          continue
                      end
                      extrema{o}(x, y, sc-1) = 1;
                  end
              end
          end
          [scx, scy] = find(extrema{o}(:,:,sc-1))
          %first octave is times2, second is same, third is 1/2
          rowVector = [rowVector; scx .* (2^(o)/4)];
          colVector = [colVector; scy .* (2^(o)/4)];
          radiusVector = [radiusVector; sqrt(2) * sc * ones(size(scy))];
      end
  end
end
