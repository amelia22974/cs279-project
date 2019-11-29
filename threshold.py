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
#import segmentImage
#import matlab.engine

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

def preprocess(img):

    im = ImageOps.autocontrast(img, 100, 0)
    im = PIL.ImageOps.invert(im)
    im = im.filter(ImageFilter.UnsharpMask(radius=2, percent=500, threshold=3))

    im = np.array(im)

    for i in range(im.shape[0]):
        for j in range(im.shape[1]):
            if im[i,j] >= 50:
                im[i,j] = 255

    #im = Image.fromarray(im, mode='L')
    return im

def kmeans(img):
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

if __name__ == "__main__":

    # load image from command line
    import sys
    # for now we just want an image path as input
    if len(sys.argv) != 2:
        print("usage: {} <image_file>".format(sys.argv[0]))
    image_name = sys.argv[1]

    img = Image.open(image_name)
    red, green, blue = split_image(img)
    #red.show()
    #img.show()
    #green.show()
    #blue.show()

    red2 = preprocess(red)
    green2 = preprocess(green)
    blue2 = preprocess(blue)

    # turn image channels into numpy arrays accessible to cv2 functions
    #red = np.array(red) 
    #blue = np.array(blue)
    #green = np.array(green)

    img1 = cv2.imread(image_name)
    img1 = color_thresh(img1, red2)
    #img1 = Image.fromarray(img1)

    kmeans(img1)
    #segmentImage.segmentImage(img1)
    #watershed(img1)
    #im = Image.fromarray(img1, mode='L')
    #im.show()



