%%
% So, now we have this really basic information about the images
% Our next step is to idenitfy dendrites with considerable accuracy.
% We first do some simple processing on the image to maximise sensitivity. 
clear all 
close all

img = imread('/Users/sidsd27/Downloads/test2.jpg');
img= imsharpen(img, 'Radius', 4, 'Amount', 1.5);
A = img;
imshow(img);

prompt = 'What color is your cell-fill marker? ';
str = input(prompt,'s');
if isempty(str) or
    str = 'red';
end
%Select your channels here. We've eliminates irrelevant ones. This is done
%manually as of now
if strcmpi(str, 'red')
    m= 1;
    n = 2
    o =3
elseif strcmpi(str, 'green')
    m= 2;
    n = 3;
    o =1;
elseif strcmpi(str, 'blue')
    m= 3;
    n = 2;
    o =1;
end
A(:,:,n)=0;
A(:,:,o) = 0;

% Here we do a k means based segmentation using 6 clusters 
[L,C] = imsegkmeans(A,6);
A = label2rgb(L,im2double(C));
imshow(A)
hold on 
close all



%%    
%Multiple iterations of gaussian filtering at a low SD to preserve edges we want 
% but eliminate all the noise in the image.
for i =1:1000
    A = imgaussfilt(A,1);
end
imshow(A)
%% Soma detection pre-processing

f=A; 
thresh = graythresh(f(:,:,m));
f = imbinarize(f(:,:,m), thresh);
imshow(f)

%%
%Use the fibermetric algorithm to identify dendrites based on tubularity and then process 
% image accordingly. This can take a while to run 

C=A;
A = fibermetric(A,'ObjectPolarity','bright');
A(~A) = true;

%Here we threshold our images 
thresh = graythresh(A(:,:,m));
A = imbinarize(A(:,:,m), thresh);
A=imfill(A, 16);
A = imcomplement(A);


%% 
%Creates a structural object and uses it to dilate the image
se = strel('disk', 1, 4);
A = imdilate(A, se);


%% 
%Creates a skeleton of the image and thins it

skel = bwskel(A, 'MinBranchLength', 1000);
skel = imclose(skel,se);
skel = bwmorph(A, 'thin', Inf); 


%%
%Geodesic distance transform 
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
imshow(skelD);

%%
% A bunch of other processing to get rid of spurious dendrites that don't
% fit our criteria
figure(6)
skelD = bwmorph(skelD, 'close', 10);
skelD = bwmorph(skelD, 'fill', 10);
skelD = bwmorph(skelD, 'bridge', 5);
skelD = bwmorph(skelD, 'spur');
skelD = bwmorph(skelD, 'hbreak');
title('Here is a comparison between our final map and the original image')
imshowpair(skelD, img, 'montage');
%% Let's also get some useful data out of this
B = bwmorph(skelD, 'branchpoints');
figure, imshowpair(B, skelD, 'montage');
B = bwmorph(B, 'close', 10);
B = bwmorph(B, 'fill', 10);
B = bwmorph(B, 'bridge', 5);
B = bwmorph(B, 'spur');
B = bwmorph(B, 'hbreak');

imshow(B);
statsBranches = regionprops('table',B,'Centroid', 'Area');
imshowpair(skelD, B, 'montage');
%% This gives you the number of branchpoints as a good measure of 
% dendritic arborisation that is commonly used in neurobiology 
disp('number of branchpoints = ') 
logical = statsBranches.Area(statsBranches.Area < 2);
disp(sum(logical==1));

%% %% Our next goal is to find some way of quanitfying dendiritic arborization in a way that might be useful to researchers 
while(1)
    neuriteask=input('Do you want to select a neurite?, Y/N [Y]: ','s')
    scale = input('Do you want to select a scale factor, default: pixels ')
 if isempty(scale)
     scale =1;
 end
if strcmpi(neuriteask, 'n')
break
end
figure(10)
img = imshow(skelD);
roi = drawassisted(img,'Color','r', 'Closed', false);
skeletonmask = createMask(roi);
imshow(skeletonmask);
statsmask = regionprops(skeletonmask, 'MajorAxis', 'Perimeter');
  
Neurite_length1 = statsmask.Perimeter/2 .* scale

end


%% Our next goal is to find some way of quanitfying dendiritic arborization in a way that might be useful to researchers 
%Let's make a GUI for this: Credit to mathworks for some of this code
sz = size(skeletonmask);
myData.Units = 'pixels';
myData.MaxValue = hypot(sz(1),sz(2));
myData.Colormap = hot;
myData.ScaleFactor = 1;

hIm = imshow(skelD);

hIm.ButtonDownFcn = @(~,~) startDrawing(hIm.Parent,myData);
function startDrawing(hAx,myData)

% Create a line ROI object. Specify the initial color of the line and
% store the |myData| structure in the |UserData| property of the ROI.
h = images.roi.Line('Color',[0, 0, 0.5625],'UserData',myData);

% Set up a listener for movement of the line ROI. When the line ROI moves,
% the |updateLabel| callback updates the text in the line ROI label and
% changes the color of the line, based on its length.
addlistener(h,'MovingROI',@updateLabel);

% Set up a listener for clicks on the line ROI. When you click on the line
% ROI, the |updateUnits| callback opens a GUI that lets you specify the
% known distance in real-world units, such as, meters or feet.
addlistener(h,'ROIClicked',@updateUnits);

% Get the current mouse location from the |CurrentPoint| property of the
% axes and extract the _x_ and _y_ coordinates.
cp = hAx.CurrentPoint;
cp = [cp(1,1) cp(1,2)];

% Begin drawing the ROI from the current mouse location. Using the
% |beginDrawingFromPoint| method, you can draw multiple ROIs.
h.beginDrawingFromPoint(cp);

% Add a custom option to the line ROI context menu to delete all existing
% line ROIs.
c = h.UIContextMenu;
uimenu(c,'Label','Delete All','Callback',@deleteAll);

end

function updateLabel(src,evt)

% Get the current line position.
pos = evt.Source.Position;

% Determine the length of the line.
diffPos = diff(pos);
mag = hypot(diffPos(1),diffPos(2));

% Choose a color from the color map based on the length of the line. The
% line changes color as it gets longer or shorter.
color = src.UserData.Colormap(ceil(64*(mag/src.UserData.MaxValue)),:);

% Apply the scale factor to line length to calibrate the measurements.
mag = mag*src.UserData.ScaleFactor;

% Update the label.
set(src,'Label',[num2str(mag,'%30.1f') ' ' src.UserData.Units],'Color',color);

end

function updateUnits(src,evt)

% When you double-click the ROI label, the example opens a popup dialog box
% to get information about the actual distance. Use this information to
% scale all line ROI measurements.
if strcmp(evt.SelectionType,'double') && strcmp(evt.SelectedPart,'label')

    % Display the popup dialog box.
    answer = inputdlg({'Known distance','Distance units'},...
        'Specify known distance',[1 20],{'10','meters'});

    % Determine the scale factor based on the inputs.
    num = str2double(answer{1});

    % Get the length of the current line ROI.
    pos = src.Position;
    diffPos = diff(pos);
    mag = hypot(diffPos(1),diffPos(2));

    % Calculate the scale factor by dividing the known length value by the
    % current length, measured in pixels.
    scale = num/mag;

    % Store the scale factor and the units information in the |myData|
    % structure.
    myData.Units = answer{2};
    myData.MaxValue = src.UserData.MaxValue;
    myData.Colormap = src.UserData.Colormap;
    myData.ScaleFactor = scale;

    % Reset the data stored in the |UserData| property of all existing line
    % ROI objects. Use |findobj| to find all line ROI objects in the axes.
    hAx = src.Parent;
    hROIs = findobj(hAx,'Type','images.roi.Line');
    set(hROIs,'UserData',myData);

    % Update the label in each line ROI object, based on the information
    % collected in the input dialog.
    for i = 1:numel(hROIs)

        pos = hROIs(i).Position;
        diffPos = diff(pos);
        mag = hypot(diffPos(1),diffPos(2));

        set(hROIs(i),'Label',[num2str(mag*scale,'%30.1f') ' ' answer{2}]);

    end

    % Reset the |ButtonDownFcn| callback function with the current |myData|
    % value.
    hIm = findobj(hAx,'Type','image');
    hIm.ButtonDownFcn = @(~,~) startDrawing(hAx,myData);

end

end

%%
function allevents(src,evt)
    evname = evt.EventName;
    switch(evname)
        case{'MovingROI'}
            disp(['ROI moving previous position: ' mat2str(evt.PreviousPosition)]);
            disp(['ROI moving current position: ' mat2str(evt.CurrentPosition)]);
        case{'ROIMoved'}
            disp(['ROI moved previous position: ' mat2str(evt.PreviousPosition)]);
            disp(['ROI moved current position: ' mat2str(evt.CurrentPosition)]);
    end
end






















