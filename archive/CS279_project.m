%A = imread('/Users/ianwoodward/Documents/GitRepos/cs279-project/imgs/trial1.jpg');
A = imgetfile();
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

% Get centroid data for output
  BWGreen = imfill(greenChannel, 'holes');
  BWGreen= imclearborder(BWGreen);
  stats = regionprops('table', BWGreen,'Centroid', 'Area');
  centroid_x = stats.Centroid(:,1);
  centroid_y = stats.Centroid(:,2);
  area = stats.Area
  
  t = table(centroid_x, centroid_y, area)
  writetable(t,'centroid_output.csv');
  
  %%SAVE info to file for later reference
  imshow(BWGreen);

  figure(8)
  imshow(BWred)
  hold on
  plot(stats.Centroid(:,1), stats.Centroid(:,2), 'r*');
  hold off
  figure(9)
  imshow(A)
  figure(10)
  imshow(BWred)
 
  
  
  
 









