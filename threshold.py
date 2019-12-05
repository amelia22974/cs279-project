# FILE: threshold.py
# This file takes a fluorescence microscopy image of cells labelled with antibodies and will eventually calculate
# number of puncta.
# WE DECIDED TO SWITCH TO IMPLEMENTATION IN MATLAB BECAUSE THE MATLAB TO PYTHON API IS EXTREMELY SLOW AND NOT 
# VERY PRACTICAL FOR REAL USE OF OUR TOOL.
import numpy as np
import random
import math
import PIL
from PIL import Image, ImageDraw, ImageFilter, ImageOps, ImageEnhance
import cv2
from matplotlib import pyplot as plt
import matlab.engine

def split_image(image_name):
    """
        Splits image into R,G,B channels, returning each as a separate Image object.
    """
    #pil_image = Image.fromarray(image_name)
    red, green, blue = img.split()

    return red, green, blue

def color_thresh(orig_img, thresh_img):
    """
    Applies dynamic threshold filter for an individual channel to colored original microscopic img.
    Input: 
    - orig_img (as numpy array);
    - thresh_img 
    Output:

    """
    new_img = orig_img

    for i in range(orig_img.shape[0]):
        for j in range(orig_img.shape[1]):
            if thresh_img[i,j] == 255:
                new_img[i,j] = 0

    return new_img

def fillout(img):
    h, w = img.shape[:2]
    mask = np.zeros((h+2, w+2), np.uint8)

    im_floodfill = img

    # Floodfill from point (0, 0)
    cv2.floodFill(im_floodfill, mask, (0,0), 255);
 
    # Invert floodfilled image
    im_floodfill_inv = cv2.bitwise_not(im_floodfill)
 
    # Combine the two images to get the foreground.
    im_out = img | im_floodfill_inv
    return im_out

def preprocess(img, cutoff=220):

    im = ImageOps.autocontrast(img, 100, 0)
    im = im.filter(ImageFilter.UnsharpMask(radius=2, percent=100, threshold=3))
    im = PIL.ImageOps.invert(im)

    im = np.array(im)

    #Helps to clean up noise, value cutoff should really be adjustable!
    for i in range(im.shape[0]):
        for j in range(im.shape[1]):
            if im[i,j] >= cutoff:
                im[i,j] = 255

    #im = Image.fromarray(im, mode'L')
    return im

def kmeans(img):
    """
    Credits: https://towardsdatascience.com/introduction-to-image-segmentation-with-k-means-clustering-83fd0a9e2fc3
    """
    img=cv2.cvtColor(img,cv2.COLOR_BGR2RGB)
    vectorized = img.reshape((-1,3))
    vectorized = np.float32(vectorized)
    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 10, 1.0)
    K = 3
    attempts=10
    ret,label,center=cv2.kmeans(vectorized,K,None,criteria,attempts,cv2.KMEANS_PP_CENTERS)
    center = np.uint8(center)
    res = center[label.flatten()]
    result_image = res.reshape((img.shape))

    figure_size = 10

    plt.figure(figsize=(figure_size,figure_size))
    plt.subplot(1,2,1),plt.imshow(img)
    plt.title('Original Image'), plt.xticks([]), plt.yticks([])
    plt.subplot(1,2,2),plt.imshow(result_image)
    plt.title('Segmented Image when K = %i' % K), plt.xticks([]), plt.yticks([])
    plt.show()

    return result_image

def binarize(img):

    for i in range(img.size[0]):
        for j in range(img.size[1]):
            if img[i,j] < 50:
                img[i,j] = 0
            else:
                img[i,j] = 1

if __name__ == "__main__":

    # load image from command line
    import sys
    image_name = sys.argv[1]


    img = Image.open(image_name)

    print "Splitting channels..."
    red, green, blue = split_image(img)

    red2 = preprocess(red)
    green2 = preprocess(green)
    blue2 = preprocess(blue)

    img1 = cv2.imread(image_name)
    clr_thresh = color_thresh(img1, green2)

    print "Calculating kmeans..."
    
    img1 = cv2.imread(image_name)
    red_thresh = color_thresh(img1, red2)
    redk = kmeans(red_thresh)

    img1 = cv2.imread(image_name)
    green_thresh = color_thresh(img1, green2)
    greenk = kmeans(green_thresh)

    img1 = cv2.imread(image_name)
    blue_thresh = color_thresh(img1, blue2)
    bluek = kmeans(blue_thresh)

    # Turn to grayscale

    redk = cv2.cvtColor(redk, cv2.COLOR_BGR2GRAY)
    greenk = cv2.cvtColor(greenk, cv2.COLOR_BGR2GRAY)
    bluek = cv2.cvtColor(bluek, cv2.COLOR_BGR2GRAY)

    cv2.imwrite('red_out.png',redk)
    cv2.imwrite('blue_out.png',bluek)    
    cv2.imwrite('green_out.png',greenk)

    #Load up the MATLAB engine
    print "Opening MATLAB"
    eng = matlab.engine.start_matlab()
    print "Matlab takes way too long to open and execute functions!"
    r = eng.imread()

    #g_level = eng.graythresh(green_img);
    #green_b = eng.imbinarize(blue_img, g_level)

    #b_level = eng.graythresh(blue_img);
    #blue_b = eng.imbinarize(green_img, b_level)

    #b = eng.imfill(binary, 'holes')
    #b = eng.imclearborder(b)
    #print "Got past imclearborder"
    #stats = eng.regionprops('table', b,'Centroid', 'Area')
    #print stats

    #roi = eng.drawfreehand()
    #level = eng.graythresh(redChannel);
    #BW = eng.imbinarize(img, 50);
    eng.quit()




