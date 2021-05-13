function extrema = generateExtrema(num_of_octaves, log_scales_per_octave, scale_space, s)
  extrema = cell(num_of_octaves, 1);
  sc = 1; %initialize for taking correct scale_space image
  for o = 1:num_of_octaves
      extrema{o} = zeros(size(scale_space{o, sc}, 1), size(scale_space{o, sc}, 2), s);
      for sc = 2:log_scales_per_octave-1
          for x = 2:size(scale_space{o, sc}, 1)-1
              for y = 2:size(scale_space{o, sc}, 2)-1
                  neighbors = scale_space{o, sc}(x-1:x+1, y-1:y+1)(:);
                  neighbors(5) = [];
                  % neighbors now contains 8 neighbors from the current layer
                  % we have to add 9 neighbors from the previous layer, and 9 neighbors from the next layer
                  neighbors = vertcat(neighbors, ...
                                      scale_space{o, sc-1}(x-1:x+1, y-1:y+1)(:), ...
                                      scale_space{o, sc+1}(x-1:x+1, y-1:y+1)(:));
                  % we now have 26 neighbors
                  sample_point = scale_space{o, sc}(x, y);
                  % compare each sample point with its 26 neighbors
                  % select it if it's larger than all of these neighbors or smaller than all of them
                  if sample_point > max(neighbors) || sample_point < min(neighbors)
                      % reject unstable extrema with low contrast
                      % dx = scale_space{o, sc}(x+1, y) - scale_space{o, sc}(x-1, y);
                      % dy = scale_space{o, sc}(x, y+1) - scale_space{o, sc}(x, y-1);
                      % ds = scale_space{o, sc+1}(x, y) - scale_space{o, sc-1}(x, y);
                      % dD = [dx, dy, ds];
                      % xhat = [???];
                      % Dxhat = scale_space{o, sc}(x, y) + 0.5 * (dD * xhat);
                      % if abs(Dxhat) < 0.03
                      %     continue
                      % end
                      %
                      % Eliminating Edge Responses
                      Dxx = scale_space{o, sc}(x+1, y) - scale_space{o, sc}(x-1, y);
                      Dyy = scale_space{o, sc}(x, y+1) - scale_space{o, sc}(x, y-1);
                      Dxy = scale_space{o, sc}(x-1, y+1) - scale_space{o, sc}(x-1, y-1) - scale_space{o, sc}(x+1, y+1) + scale_space{o, sc}(x+1, y-1);
                      TrH = Dxx + Dyy;
                      DetH = Dxx*Dyy - Dxy^2;
                      r = 10;
                      if ((TrH^2 / DetH) >= (r+1)^2 / r)
                          continue
                      end
                      extrema{o}(x, y, sc-1) = 1;
                  end
              end
          end
      end
  end
end
