%%
% So, now we have this really basic information about the images
% Our next step is to idenitfy dendrites with considerable accuracy
% and find a way to calculate the number of puncta/dedndrite.
img = imread('/Users/sidsd27/Downloads/images.jpeg');
A = img;

%Select your channels here....Don't pick the wrond ones. If in doubt, 
% just use all three. 
A(:,:,1)=0;
A(:,:,3) = 0;
%if the noise is green in color
[L,C] = imsegkmeans(A,3);
A = label2rgb(L,im2double(C));


figure(68)
imshow(A)
hold on

%% We're gonna filter this shit first
for i =1:1000
    A = imgaussfilt(A,1);
    
end
%% Smmoooothh
figure(500);
title('Gaussian Smoothing')
imshow(A);
%% Use the fibermetric algorithm
C=A;
A = fibermetric(A,'ObjectPolarity','bright');
A(~A) = true;
figure(69)
imshow(A)
hold on
thresh = graythresh(A(:,:,2));
A = imbinarize(A(:,:,2), thresh);
A=imfill(A, 16);
A = imcomplement(A);
figure(1)
imshowpair(C,A, 'montage');
hold on
%%
 figure(2)
se = strel('disk', 1, 4);
A = imdilate(A, se);
imshow(A)
hold on
%%

skel = bwskel(A, 'MinBranchLength', 500);
skel = imclose(skel,se);
skel = bwmorph(A, 'thin', Inf)
figure(3)
imshowpair(C, skel, 'montage')
hold on

%% Geodesic distance trasnform

B = bwmorph(skel, 'branchpoints');
E = bwmorph(skel, 'endpoints');
[y,x] = find(E);
B_loc = find(B);
Dmask = false(size(skel));
for k = 1:numel(x)
    D = bwdistgeodesic(skel,x(k),y(k));
    distanceToBranchPt = min(D(B_loc));
    Dmask(D < distanceToBranchPt) =true;
end
skelD = skel - Dmask;
figure(4)
imshowpair(skelD, skel, 'montage');
hold all;
% [y,x] = find(B); plot(x,y,'ro')
%%
figure(5)
imshowpair(img, skelD, 'montage');

%%


















