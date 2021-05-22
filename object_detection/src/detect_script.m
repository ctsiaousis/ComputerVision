%
% This is a simple test script to exercise the detection code.
%
% It assumes that the template is exactly 16x16 blocks = 128x128 pixels.  
% You will want to modify it so that the template size in blocks is a
% variable you can specify in order to run on your own test examples
% where you will likely want to use a different sized template
%

% load a training example image
Itrain = im2double(rgb2gray(imread('facetest/faces5.jpg')));

%have the user click on some training examples.  
% If there is more than 1 example in the training image (e.g. faces), you could set nclicks higher here and average together
nclick = 5;
figure(1); clf;
imshow(Itrain);
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
  figure(2); subplot(3,2,i); imshow(patch);
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


% now compute the average template for the negative examples
negtemplate = zeros(16,16,9);

% our final classifier is the difference between the positive
% and negative averages
template = postemplate - negtemplate;


%
% load a test image
%
Itest= im2double(rgb2gray(imread('facetest/faces3.jpg')));


% find top 8 detections in Itest
ndet = 8;
[x,y,score] = detect(Itest,template,ndet);
ndet = length(x);

%display top ndet detections
figure(3); clf; imshow(Itest);
for i = 1:ndet
  % draw a rectangle.  use color to encode confidence of detection
  %  top scoring are green, fading to red
  hold on; 
  h = rectangle('Position',[x(i)-64 y(i)-64 128 128],'EdgeColor',[(i/ndet) ((ndet-i)/ndet)  0],'LineWidth',3,'Curvature',[0.3 0.3]); 
  hold off;
end
