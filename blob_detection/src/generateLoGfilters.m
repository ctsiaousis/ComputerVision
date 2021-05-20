function log_filters = generateLoGfilters(log_scales_per_octave, ...
                                            k, sigma, boolVis, ...
                                            isEfficient)
  if boolVis %only for visualization
    figure
  end
  log_filters = cell(log_scales_per_octave, 1);
  for i = 1:log_scales_per_octave
      k_power = i-1;
      sigma_prime = k^k_power * sigma;
      % D(x,y,σ) = (G(x,y,kσ)-G(x,y,σ))∗I(x,y)
      % "the difference between the [Gaussian] images
      %  at scales κσ and σ is attributed a blur level σ"
      log_filters{i} = (k - 1) * sigma_prime^2 * ...
          fspecial('log', floor(4*sigma_prime) * 2 + 1, sigma_prime);
      
      if boolVis && ~isEfficient %only for visualization
        subplot(1, log_scales_per_octave, i)
        s = mesh(log_filters{i});
        s.FaceColor = 'interp';
        set(gca, 'PlotBoxAspectRatio', [1,1,1])
      end
      if isEfficient && boolVis
        s = mesh(log_filters{i});
        s.FaceColor = 'interp';
        set(gca, 'PlotBoxAspectRatio', [1,1,1])
        break
      end
  end
end
