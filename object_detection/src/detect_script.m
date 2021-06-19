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
figure(1); clf;
imshow(Itrain);
title(sprintf('Select %d faces for the template',nclick));
[x,y] = ginput(nclick); %get nclicks from the user

%compute 8x8 block in which the user clicked
blockx = round(x/8);
blocky = round(y/8); 

%visualize image patch that the user clicked on
% the patch shown will be the size of our template
% since the template will be 16x16 blocks and each
% block is 8 pixels, visualize a 128pixel square 
% around the click location.
figure(2); clf;
for i = 1:nclick
  patch = Itrain(8*blocky(i)+(-63:64),8*blockx(i)+(-63:64));
  figure(2); subplot(ceil(nclick/2),2,i); imshow(patch);
end

% compute the hog features
f = hog(Itrain);

% compute the average template for the user clicks
postemplate = zeros(16,16,9);
for i = 1:nclick
  postemplate = postemplate + f(blocky(i)+(-7:8),blockx(i)+(-7:8),:); 
end
postemplate = postemplate/nclick;


% TODO: also have the user click on some negative training
% examples.  (or alternately you can grab random locations
% from an image that doesn't contain any instances of the
% object you are trying to detect).
negnclick = nclick;
figure(3); clf;
imshow(Itrain);
title(sprintf('Select %d non-faces for the negative template',negnclick));
[xx,yy] = ginput(negnclick);

%compute 8x8 block in which the user clicked
nblockx = round(xx/8);
nblocky = round(yy/8); 
figure(4); clf;
for i = 1:negnclick
  npatch = Itrain(8*nblocky(i)+(-63:64),8*nblockx(i)+(-63:64));
  figure(4); subplot(ceil(negnclick/2),2,i); imshow(npatch);
end
% now compute the average template for the negative examples
negtemplate = zeros(16,16,9);
% TODO -- not good enough. Maybe the issue is on the detect func
for i = 1:negnclick
  negtemplate = negtemplate + f(nblocky(i)+(-7:8),nblockx(i)+(-7:8),:);
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
  figure(5+j); clf; imshow(Itest);
  for i = 1:ndet
    % draw a rectangle.  use color to encode confidence of detection
    %  top scoring are green, fading to red
    hold on; 
    h = rectangle('Position',[x(i)-64 y(i)-64 128 128],'EdgeColor',[(i/ndet) ((ndet-i)/ndet)  0],'LineWidth',3,'Curvature',[0.3 0.3]); 
    hold off;
  end
end
