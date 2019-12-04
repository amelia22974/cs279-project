 %% Colocalization of puncta 
    imwrite(RC, 'red.tif')
    imwrite(GC, 'green.tif')
    imwrite(BC, 'blue.tif')
    
    scatterOutput = CLC('red.tif','green.tif',[],2,'hot',1,1); 
    
