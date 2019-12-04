function scatterOutput = CLC(img1,pic2,scale,numCol, ...
    colMap,zeroDel,line); 
   
   
    % picture 1 (converts data to 'single' point precision)
    ImMatrix1 = single(imread(img1)); 
    % picture 2 (converts data to 'single' point precision)
    ImMatrix2 = single(imread(pic2)); 
    
    % obtains RGB triplets for the desired colormap (colMap) and number
    % of colours within this colormap (numCol).
    colMap = str2func(colMap); 
    Colours = colMap(numCol); 
   
    % pixel values for Picture1 and Picture2 arranged in adjacent columns.
    data = [ImMatrix1(:),ImMatrix2(:)]; 
   
    % counts number of occurences of each unique pixel value. Used to
    % obtain a pixel intensity identifier for each unique pixel value.
    [a,b,c] = unique(data, 'rows', 'stable'); 
    d = accumarray(c, 1); 
    maps = d(c); 
  
    % creates matrix including the pixel data (columns 1 and 2) and 
    % respective pixel counts (column 3). Deletes duplicates.
    data = [data,maps];
    data = unique(data,'rows'); 
    
    % deletes pixels with value 0 in both Picture1 and Picture2 if zeroDel
    % function input set as 1.
    if zeroDel == 1; 
        Bean = find(data(:,1) == 0 & data(:,2) == 0);
        data(Bean,:) = []; 
    end
    
    % transforms the pixel intensity identifier according to scale function
    % input.
    if scale>0;  
        scaling = str2func(scale);
        data(:,3) = scaling(data(:,3));
    end
 
    % creates bins to partition pixel intentisties along colMap 
    bins = linspace(0,max(data(:,3))+1,numCol+1); 
    
    % partitions the pixel intensity identifiers into evenly spaces bins 
    % determined by numCol
    for i = 1:numCol;
        data(find(data(:,3)>=bins(i) & data(:,3)<bins(i+1)) , 3) = i;
    end
    
    % creates the RGB triplets for each pixel
    ColIden = zeros(length(data(:,3)),3); % empty matrix
    for ii = 1:length(data(:,3)); % adds RGB values
         ColIden(ii,:) = Colours(data(ii,3),:);
    end
    
    % plots cytofluorogram. % scatter points set to '.' and size '100' as
    % default. All ticks from colorbar removed as default.
    figure(1) 
    scatter(data(:,1),data(:,2),100,ColIden,'.'); 
    colorbar('Ticks',[1],'TickLabels',{'max'}); 
    colormap(Colours); 
    xlabel('img1 brightness (au)')
    ylabel('pic2 brightness (au)')
    title('Cytofluorogram')
    
    % adds line of best fit if specified
    if line == 1; 
        
       dataLine = [ImMatrix1(:),ImMatrix2(:)];
       meandataLine = mean(dataLine,1);
       [PCAcoeffs,PCAscores] = pca(dataLine); 
       BEAN = PCAcoeffs(:,1);
       BAG = [min(PCAscores(:,1))-0.2, max(PCAscores(:,1))+0.2];
       POCKET = [meandataLine + BAG(1)*BEAN'; meandataLine + BAG(2)*BEAN'];
       figure(1);
       hold on
       plot(POCKET(:,1),POCKET(:,2),'Linewidth',2,'Color','m');
       axis([0,inf,0,inf]);
    end
    
    if line == 1
        scatterOutput = [{data},{POCKET}];
    else
        scatterOutput = [{data},{[]}];
    end
