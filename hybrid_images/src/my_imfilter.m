function output = my_imfilter(image, filter)
% This function is intended to behave like the built in function imfilter()
% See 'help imfilter' or 'help conv2'. While terms like "filtering" and
% "convolution" might be used interchangeably, and they are indeed nearly
% the same thing, there is a difference:
% from 'help filter2'
%    2-D correlation is related to 2-D convolution by a 180 degree rotation
%    of the filter matrix.

% Your function should work for color images. Simply filter each color
% channel independently.

% Your function should work for filters of any width and height
% combination, as long as the width and height are odd (e.g. 1, 7, 9). This
% restriction makes it unambiguous which pixel in the filter is the center
% pixel.

% Boundary handling can be tricky. The filter can't be centered on pixels
% at the image boundary without parts of the filter being out of bounds. If
% you look at 'help conv2' and 'help imfilter' you see that they have
% several options to deal with boundaries. You should simply recreate the
% default behavior of imfilter -- pad the input image with zeros, and
% return a filtered image which matches the input resolution. A better
% approach is to mirror the image content over the boundaries for padding.

% % Uncomment if you want to simply call imfilter so you can see the desired
% % behavior. When you write your actual solution, you can't use imfilter,
% % filter2, conv2, etc. Simply loop over all the pixels and do the actual
% % computation. It might be slow.
% output = imfilter(image, filter);

%% initialization
    assert(ismatrix(filter), 'Filter must be 2D matrix');
    h = rot90(filter, 2);               %filter rotation
    [m n] = size(h);                    %dimentions of filter
    [dummy actD] = size(size(image));   %dimentions of image
    if actD == 3
        [oL oC channels] = size(image); %original image is RGB
    else
        [oL oC] = size(image);          %original image is GRAY
        channels = 1;
    end
    assert((-1^m == -1) && (-1^n == -1),'Filter dimentions must be odd');
    lFilter = floor(m/2);
    cFilter = floor(n/2);
    pL = oL+2*lFilter;       %lines of padded image
    pC = oC+2*cFilter;       %columns of padded image

%% symmetric padding
    %padded = padarray(image, [lFilter cFilter], 'symmetric');
    padded = zeros(pL, pC, channels);
    for chan = 1 : channels
        % copy image to padded
        for x = 1 + lFilter : oL + lFilter
            for y = 1 + cFilter : oC + cFilter
                padded(x,y,chan) = image(x - lFilter, y - cFilter, chan);
            end
        end

	% calculate padding top rows
        for x = 1 : lFilter
            for y = 1 + cFilter : oC + cFilter
                padded(x,y,chan) = image(1 + lFilter - x, y - cFilter, chan);
            end
        end
	% calculate padding bottom rows
        for x = 1 + oL + lFilter : pL
            dx = x - (1 + oL + lFilter);
            for y = 1 + cFilter : oC + cFilter
                padded(x,y,chan) = image(oL - dx, y - cFilter, chan);
            end
        end

	% calculate padding left columns
        for x = 1 : pL
            for y = 1 : cFilter
                padded(x,y,chan) = padded(x, 1 + 2*cFilter - y, chan);
            end
        end
	% calculate padding right columns
        y1 = 1 + oC + cFilter;
        for x = 1 : pL
            for y = y1 : pC
                dy = y - y1;
                padded(x,y,chan) = padded(x, y1 - dy - 1, chan);
            end
        end
    end
    
%% fill the output array with zeros
    output = zeros( oL , oC , channels );

%% convolute
    for chan = 1 : channels
        for i = 1 : oL
            for j = 1 : oC
                temp = padded(i:i+2*lFilter, j:j+2*cFilter, chan) .* h;
                output(i,j, chan) = sum(sum(temp));
            end
        end
    end
    
%% check results
    assert(isequal(size(output), size(image)), 'Size mismatch, check it yourself');
end
