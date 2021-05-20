function [extrema, rowVector, colVector, radiusVector] = ...
                                generateExtrema(num_of_octaves,...
                                log_scales_per_octave, scale_space, s, ...
                                threshold, sigma, k, isEfficient)
  extrema = cell(num_of_octaves, 1);
  rowVector = []; colVector = []; radiusVector = [];
  r = 10;
  hessianThreshold = (r+1)^2 / r;
  sc = 2; %initialize for taking correct scale_space image
  for o = 1:num_of_octaves
      extrema{o} = zeros(size(scale_space{o, sc}, 1), ...
          size(scale_space{o, sc}, 2), s);
      for sc = 2:log_scales_per_octave-1
          if isEfficient %we need to count in the smaller dimension
              xMin = 4;
              yMin = 4;
              xMax = size(scale_space{o, sc+1}, 1)-1;
              yMax = size(scale_space{o, sc+1}, 2)-1;
          else
              xMin = 2;
              yMin = 2;
              xMax = size(scale_space{o, sc}, 1)-1;
              yMax = size(scale_space{o, sc}, 2)-1;
          end
          for x = 2:xMax
              for y = 2:yMax
                  tmpMid  = scale_space{o, sc}(x-1:x+1, y-1:y+1);
                  neighbors = tmpMid(:);
                  sample_point = neighbors(5);
                  neighbors(5) = [];
                  % neighbors now contains 8 neighbors from the current layer
                  % [optimization] check early for extrema in order to avoid
                  % finding all 26 neighbors.            provides x2 speedup
                  if sample_point > min(neighbors) && sample_point < max(neighbors)
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
                  if sample_point <= min(neighbors) || ...
                          sample_point >= max(neighbors)
                      % Lowe: 3.3: Eliminating Edge Responses
                      Dxx = scale_space{o, sc}(x+1, y) + ...
                            scale_space{o, sc}(x-1, y) - ...
                            2*scale_space{o, sc}(x, y);
                      Dyy = scale_space{o, sc}(x, y+1) + ...
                            scale_space{o, sc}(x, y-1) - ...
                            2*scale_space{o, sc}(x, y);
                      Dxy = scale_space{o, sc}(x-1, y+1) - ...
                            scale_space{o, sc}(x-1, y-1) - ...
                            scale_space{o, sc}(x+1, y+1) + ...
                            scale_space{o, sc}(x+1, y-1);
                      trH = Dxx + Dyy;
                      detH = Dxx*Dyy - Dxy^2;
                      if ((trH^2 / detH) >= hessianThreshold)
                          continue
                      end
                      % Otero, algorithm 8, reject low contrast keypoints
                      if(abs(sample_point) >= threshold)
                          extrema{o}(x, y, sc-1) = 1;
                          if ~isEfficient %not efficient, scale by octaves only
                              %first octave is times2, second is same, third is 1/2
                              %so we map 1->1/2, 2->1, 3->2, 4->4, 5->8, etc...
                              rowVector = [rowVector; y * (2^(o)/4)];
                              colVector = [colVector; x * (2^(o)/4)];
                          else %efficient, scale by both octaves and scales
% uncomment for explanation
% fprintf('o:%d, sc:%d, multiplier:%d\n',o,sc,(2^(o)) * (2^(sc))/4);
                              rowVector = [rowVector; y * (2^(o)) * (2^(sc))/4];
                              colVector = [colVector; x * (2^(o)) * (2^(sc))/4];
                          end
                          %bigger radius for bigger octave and scale, this means
                          %the bigger cycle is a more persistant feature
                          radiusVector = [radiusVector;  sqrt(2) * ...
                                               sigma * o * k^(sc-1)];
                      end
                  end %if (possible extrema)
              end %for each y
          end %for each x
      end %for each scale
  end %for each octave

end
