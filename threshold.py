# FILE: threshold.py
# This file takes a fluorescence microscopy image of cells labelled with antibodies and thresholds based 
# on the user's desired color (eventually).

import numpy as np
import random
import math
import PIL
from PIL import Image, ImageDraw, ImageFilter, ImageOps, ImageEnhance
import cv2
from matplotlib import pyplot as plt

def split_image(image_name):
    """
        Splits image into R,G,B channels, returning each as a separate Image object.
    """
    #pil_image = Image.fromarray(image_name)
    red, green, blue = img.split()

    return red, green, blue


def sharpen_image(img):
    """
        A function to be called if we need image sharpenging
    """
    im = ImageEnhance.Contrast(img).enhance(0.9)

def adaptive_thresholding(img):
    """
    Credits: https://docs.opencv.org/master/d7/d4d/tutorial_py_thresholding.html
    """
    img = cv2.medianBlur(img,5)
    ret,th1 = cv2.threshold(img,127,255,cv2.THRESH_BINARY)
    th2 = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_MEAN_C,\
            cv2.THRESH_BINARY,11,2)
    th3 = cv2.adaptiveThreshold(img,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C,\
            cv2.THRESH_BINARY,11,2)
    titles = ['Original Image', 'Global Thresholding (v = 127)',
            'Adaptive Mean Thresholding', 'Adaptive Gaussian Thresholding']
    images = [img, th1, th2, th3]

    #UNCOMMENT to display the different types of threshold images
    for i in xrange(4):
        plt.subplot(2,2,i+1),plt.imshow(images[i],'gray')
        plt.title(titles[i])
        plt.xticks([]),plt.yticks([])
    plt.show()

    return img, th1, th2, th3

def watershed(img):
    """
    Credits: https://docs.opencv.org/master/d3/db4/tutorial_py_watershed.html
    """
    gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
    
    ret, thresh = cv2.threshold(gray,0,255,cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU)
    # noise removal
    kernel = np.ones((3,3),np.uint8)
    opening = cv2.morphologyEx(thresh,cv2.MORPH_OPEN,kernel, iterations = 2)
    # sure background area
    sure_bg = cv2.dilate(opening,kernel,iterations=3)
    # Finding sure foreground area
    dist_transform = cv2.distanceTransform(opening,cv2.DIST_L2,5)
    ret, sure_fg = cv2.threshold(dist_transform,0.7*dist_transform.max(),255,0)
    # Finding unknown region
    sure_fg = np.uint8(sure_fg)
    unknown = cv2.subtract(sure_bg,sure_fg)
    # Marker labelling
    ret, markers = cv2.connectedComponents(sure_fg)
    # Add one to all labels so that sure background is not 0, but 1
    markers = markers+1
    # Now, mark the region of unknown with zero
    markers[unknown==255] = 0

    markers = cv2.watershed(img,markers)
    img[markers == -1] = [255,255,0]

    #img = cv2.resize(img,None,fx=0.5,fy=0.5,interpolation=cv2.INTER_CUBIC)
    #img = cv2.resize(img,(500,300),interpolation=cv2.INTER_AREA)

    cv2.imshow("Watershed output", img)
    #plt.imshow(color)

    cv2.waitKey()

def color_thresh(orig_img, thresh_img):
    """
    Applies dynamic threshold filter for an individual channel to colored original microscopic img.
    Input: 
    - orig_img (as numpy array);
    - thresh_img 
    Output:

    """
    for i in range(orig_img.shape[0]):
        for j in range(orig_img.shape[1]):
            if thresh_img[i,j] == 0:
                orig_img[i,j] = 5

    return orig_img

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



if __name__ == "__main__":

    # load image from command line
    import sys
    # for now we just want an image path as input
    if len(sys.argv) != 2:
        print("usage: {} <image_file>".format(sys.argv[0]))
    image_name = sys.argv[1]

    img = Image.open(image_name)
    red, green, blue = split_image(img)

    # turn image channels into numpy arrays accessible to cv2 functions
    red = np.array(red) 
    blue = np.array(blue)
    green = np.array(green)

    red_img, red_th1, red_th2, red_th3 = adaptive_thresholding(red)
    green_img, green_th1, green_th2, green_th3 = adaptive_thresholding(green)
    blue_img, blue_th1, blue_th2, blue_th3 = adaptive_thresholding(blue)
    
    #h, w = green_th1.shape[:2]
    #mask = np.zeros((h+2, w+2), np.uint8)

    #im_floodfill = red_th1

    # Floodfill from point (0, 0)
    #cv2.floodFill(im_floodfill, mask, (0,0), 255);
 
    # Invert floodfilled image
    #im_floodfill_inv = cv2.bitwise_not(im_floodfill)
 
    # Combine the two images to get the foreground.
    #im_out = red_th1 | im_floodfill_inv
    #im_out = fillout(green_th2)

    #cv2.imshow("hi", im_out)
   # cv2.waitKey()
    img1 = cv2.imread(image_name)
    img1 = color_thresh(img1, red_th2)
    watershed(img1)




