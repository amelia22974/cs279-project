A = imread('/Users/sidsd27/Downloads/TAX3_illu2_opt.tiff');
imshow(A);
redChannel = A(:,:,1); % Red channel
greenChannel = A(:,:,2); % Green channel
blueChannel = A(:,:,3); 
figure (1)
imshow(redChannel);
hold on
 figure(2)
 imshow(greenChannel);
 hold on 
 figure(3)
 imshow(blueChannel);
 hold on 

%% 

level = graythresh(greenChannel);
BWgreen = imbinarize(greenChannel, level);
BWred = imbinarize(redChannel, level);
BWblue = imbinarize(blueChannel, level);
figure(5)
imshowpair(greenChannel, BWgreen, 'montage')
hold on 
figure(6)
imshowpair(blueChannel, BWblue, 'montage')
hold on 
figure(7)
imshowpair(redChannel, BWred, 'montage')
hold on 
%%
  BWred = imfill(BWred, 'holes')
  BWred= imclearborder(BWred)
  stats = regionprops('table', BWred,'Centroid', 'Area');
  imshow(BWred);
  stats.Centroid
  stats.Centroid(:,1)
  %%
  figure(8)
  imshow(BWred)
  hold on
  plot(stats.Centroid(:,1), stats.Centroid(:,2), 'r*');
  hold off
  figure(9)
  imshow(A)
  figure(10)
  imshow(BWred)
 
  
  
  
 









