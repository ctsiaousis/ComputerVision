%
% This is a simple test script to exercise the detection code.
%
% It assumes that the template is exactly 16x16 blocks = 128x128 pixels.  
% You will want to modify it so that the template size in blocks is a
% variable you can specify in order to run on your own test examples
% where you will likely want to use a different sized template
%

% load a training example image
Itrain = im2double(rgb2gray(imread('../data/faces1.jpg')));
% load test images (a similar image, a rotated image, a scaled image, and faces2.jpg)
Itests = {im2double(rgb2gray(imread('../data/faces1_b.jpg'))), ...
          rot90(im2double(rgb2gray(imread('../data/faces1_b.jpg')))), ...
          imresize(im2double(rgb2gray(imread('../data/faces1_b.jpg'))), 2), ...
          im2double(rgb2gray(imread('../data/faces2.jpg')))};
%have the user click on some training examples.  
% If there is more than 1 example in the training image (e.g. faces), you could set nclicks higher here and average together
nclick = 4;
figure; clf;
imshow(Itrain);
title(sprintf('Select %d faces for the template',nclick));
[x,y] = ginput(nclick); %get nclicks from the user

block_size = 8;
%compute 8x8 block in which the user clicked
blockx = round(x/block_size);
blocky = round(y/block_size);

%visualize image patch that the user clicked on
% the patch shown will be the size of our template
% since the template will be 16x16 blocks and each
% block is 8 pixels, visualize a 128pixel square 
% around the click location.
figure; clf;
for i = 1:nclick
  patch = Itrain(block_size*blocky(i)+(-block_size^2+1:block_size^2),block_size*blockx(i)+(-block_size^2+1:block_size^2));
  subplot(ceil(nclick/2),2,i); imshow(patch);
end

% compute the hog features
f = hog(Itrain);
figure; imshow(hogdraw(f))

% compute the average template for the user clicks
postemplate = zeros(2*block_size,2*block_size,9);
for i = 1:nclick
  postemplate = postemplate + f(blocky(i)+(-block_size+1:block_size),blockx(i)+(-block_size+1:block_size),:);
end
postemplate = postemplate/nclick;


% TODO: also have the user click on some negative training
% examples.  (or alternately you can grab random locations
% from an image that doesn't contain any instances of the
% object you are trying to detect).
negnclick = nclick;
figure; clf;
imshow(Itrain);
title(sprintf('Select %d non-faces for the negative template',negnclick));
[x,y] = ginput(negnclick);

%compute 8x8 block in which the user clicked
nblockx = round(x/8);
nblocky = round(y/8);
figure; clf;
for i = 1:negnclick
  npatch = Itrain(block_size*nblocky(i)+(-block_size^2+1:block_size^2),block_size*nblockx(i)+(-block_size^2+1:block_size^2));
  subplot(ceil(negnclick/2),2,i); imshow(npatch);
end
% now compute the average template for the negative examples
negtemplate = zeros(2*block_size,2*block_size,9);
% TODO -- not good enough. Maybe the issue is on the detect func
for i = 1:negnclick
  negtemplate = negtemplate + f(nblocky(i)+(-block_size+1:block_size),nblockx(i)+(-block_size+1:block_size),:);
end
negtemplate = negtemplate/negnclick;

% our final classifier is the difference between the positive
% and negative averages
template = postemplate - negtemplate;


for j = [1:length(Itests)]
  Itest = Itests{j};

  % find top 8 detections in Itest
  ndet = 8;
  [x,y,score] = detect(Itest,template,ndet);
  ndet = length(x);

  %display top ndet detections
  figure; clf; imshow(Itest);
  for i = 1:ndet
    % draw a rectangle.  use color to encode confidence of detection
    %  top scoring are green, fading to red
    hold on; 
    h = rectangle('Position',[x(i)-64 y(i)-64 128 128],'EdgeColor',[(i/ndet) ((ndet-i)/ndet)  0],'LineWidth',3,'Curvature',[0.3 0.3]); 
    hold off;
  end
end
