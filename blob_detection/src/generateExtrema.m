function [extrema, rowVector, colVector, radiusVector] = generateExtrema(num_of_octaves, log_scales_per_octave, scale_space, s, threshold)
  extrema = cell(num_of_octaves, 1);
  rowVector = []; colVector = []; radiusVector = [];
  r = 10;
  hessianThreshold = (r+1)^2 / r;
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
                  % we have to add 9 neighbors from the previous layer,
                  % and 9 neighbors from the next layer
                  tmpPrev  = scale_space{o, sc-1}(x-1:x+1, y-1:y+1);
                  tmpNext = scale_space{o, sc+1}(x-1:x+1, y-1:y+1);
                  neighbors = vertcat(neighbors,tmpPrev(:),tmpNext(:));
                  % we now have 26 neighbors
                  % compare each sample point with its 26 neighbors
                  % select it if it's larger than all of these neighbors
                  % or smaller than all of them
                  if sample_point >= max(neighbors) || sample_point <= min(neighbors)
                      % Lowe: 4.1. Eliminating Edge Responses
                      Dxx = scale_space{o, sc}(x+1, y) - 2*scale_space{o, sc}(x, y) + scale_space{o, sc}(x-1, y);
                      Dyy = scale_space{o, sc}(x, y+1) - 2*scale_space{o, sc}(x, y) + scale_space{o, sc}(x, y-1);
                      Dxy = scale_space{o, sc}(x-1, y+1) - scale_space{o, sc}(x-1, y-1) - scale_space{o, sc}(x+1, y+1) + scale_space{o, sc}(x+1, y-1);
                      trH = Dxx + Dyy;
                      detH = Dxx*Dyy - Dxy^2;
                      if ((trH^2 / detH) >= hessianThreshold)
                          continue
                      end
                      extrema{o}(x, y, sc-1) = 1;
                  end %if (possible extrema)
              end %for y
          end %for x
          %after exploring scale_space find non-zero extrema
          [scx, scy] = find(extrema{o}(:,:,sc-1));
          %first octave is times2, second is same, third is 1/2
          %so we map 1->1/2, 2->1, 3->2, 4->4, 5->8, etc...
          rowVector = [rowVector; scy .* (2^(o)/4)];
          colVector = [colVector; scx .* (2^(o)/4)];
          radiusVector = [radiusVector; sc * o * ones(size(scy))];
      end %for each scale
  end %for each octave
  
end
