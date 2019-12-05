%% Load the image
A = imgetfile();
A = imread(A);

color = menu('What color are the puncta you wish to quantify?','Red', 'Green','Blue');

if color == 1
    str = 'red';
elseif color == 2
    str = 'green';
elseif color == 3
    str = 'blue'; 
end

%We still need to something about the oversignalling in some channels!
% Split channels into RGB

RC = A(:,:,1); % Red channel
GC = A(:,:,2); % Green channel
BC = A(:,:,3); % Blue channel

RC(RC < 70) = 0;
GC(GC < 70) = 0;
BC(BC < 70) = 0;

%FIX BUG HERE RELATED TO ZEROED MATRIX

% User, select your region of interest
neuritetask = menu('Do you wish to specify a ROI?', 'Yes', 'No')

if neuritetask == 1
    figure(1)
    title('Select your region of Interest by drawing a closed region.');
    imshow(A)
    h = drawfreehand; % Allows user to create freehand ROI
    mask= createMask(h,A); %Creates a binary mask based on ROI
    imshow(mask);
    hold on
    %Sets all the channels to the masked image region
    RC(~mask) = false;
    BC(~mask) = false;
    GC(~mask) = false;
end

msgbox("Calculating number of puncta. Check command line for result.");
% Image pre-processing steps
    
% Sharpen all 3  channels
% Note that 'Radius' controls the number of edge pixels that are being sharpened
% 'Amount' controls the sensitivity
% This is necessary to heighten each individual signal as it can be  weak
% depending on quality
    
RC = imsharpen(RC, 'Radius', 4, 'Amount', 1);
GC = imsharpen(GC,'Radius', 4, 'Amount', 1);
BC = imsharpen(BC,'Radius', 4, 'Amount', 1);


% Now employ imadjust.
    
%Maps the intensity values in grayscale image I
%to new values in J. By default, imadjust saturates the bottom 1% and the top 1% of all pixel values.
%This operation increases the contrast of the output image J.

%Red channel first    
JRC = imadjust(RC);
    
% Blue Channel Next   
JBC = imadjust(BC);
    
% Green channel next
JGC = imadjust(GC);
    
% Now, for some denoising and watershed algorithming
    
%Let's get this red
%First some standard denoising of the pixels
JRC= wiener2(JRC);
thresh = graythresh(JRC);
JRC = imbinarize(JRC, thresh);
    
%Calculate the Euclidean distance trasnform of the image and implement the
%watershed algorithm
D = -bwdist(~JRC);
L = watershed(D);
JRC(L==0) = 0;
    
%Fill in all the holes and clear the border of the image
JRC= imclearborder(JRC);
JRC = imfill(JRC, 'holes');
    
% Now for the green. Happy St.Pat's
    
%First some standard denoising of the pixels
thresh = graythresh(JGC);
JGC= wiener2(JGC);
JGC = imbinarize(JGC, thresh);
    
%Calculate the Euclidean distance trasnform of the image and implement the
%watershed algorithm
D = -bwdist(~JGC);
L = watershed(D);
JGC(L==0) = 0;
    
%Fill in all the holes and clear the border of the image
JGC= imclearborder(JGC);
JGC = imfill(JGC, 'holes');
    
%Now for the blue, just like my mood.
    
%First some standard denoising of the pixels
thresh = graythresh(JBC);
JBC= wiener2(JBC);
JBC = imbinarize(JBC, thresh);
    
%Calculate the Euclidean distance trasnform of the image and implement the
%watershed algorithm
D = -bwdist(~JBC);
L = watershed(D);
JBC(L==0) = 0;
    
%Fill in all the holes and clear the border of the image
JBC= imclearborder(JBC);
JBC = imfill(JBC, 'holes');

%Don't freak out if you see too many centroids, could just be your channel
% Red Centroids
if strcmpi(str, 'red')
    if max(JRC) == 0
        msgbox("No signal detected");
        return;
    end
    statsR = regionprops('table', JRC,'Centroid', 'Area');
    figure(8)
    imshow(JRC)
    hold on
    plot(statsR.Centroid(:,1), statsR.Centroid(:,2), 'r*');
    figure(9)
    imshow(A);
        
%Green Centroids
elseif strcmpi(str, 'green') 
    if max(JGC) == 0
        msgbox("No signal detected");
        return;
    end
    statsG = regionprops('table', JGC,'Centroid', 'Area');
    figure(10)
    imshow(JGC)
    hold on
    plot(statsG.Centroid(:,1), statsG.Centroid(:,2), '.');
    hold off
    figure(11)
    imshow(A);
        
        
% Blue Centroids
elseif strcmpi(str, 'blue')
    if max(JBC) == 0
        msgbox("No signal detected");
        return;
    end
    statsB = regionprops('table', JBC,'Centroid', 'Area');
    figure(12)
    imshow(JBC)
    hold on
    plot(statsB.Centroid(:,1), statsB.Centroid(:,2), 'r*');
    hold off
    figure(13)
    imshow(A);
end

% Here are some stats
if strcmpi(str, 'green')
    disp('Number of puncta in green channel = ')
    disp(length(statsG.Area));
    figure(14)
    title('Puncta Area plot')
    histogram(statsG.Area,5);
    xlabel('area')
    ylabel('number of puncta');

elseif strcmpi(str, 'red')
    disp('Number of puncta in red channel = ')
    disp(length(statsR.Area));
    figure(14)
    title('Puncta Area plot')
    histogram(statsR.Area,5);
    xlabel('area')
    ylabel('number of puncta');

    
elseif strcmpi(str, 'blue')
    disp('Number of puncta in blue channel')
    disp(length(statsB.Area));
    figure(14)
    title('Puncta Area plot')
    imhist(statsB.Area);
    title('Puncta Area plot')
    histogram(statsB.Area,5);
    xlabel('area')
    ylabel('number of puncta');
end

 %Colocalization of puncta 
 imwrite(RC, 'red.tif')
 imwrite(GC, 'green.tif')
 imwrite(BC, 'blue.tif')
    
 scatterOutput = CLC('red.tif','green.tif',[],2,'hot',1,1); 

