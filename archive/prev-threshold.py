import numpy as np
import random
import math
import PIL
from PIL import Image, ImageDraw, ImageFilter, ImageOps, ImageEnhance

def remove_background(img):
    """
        A little PIL image processing magic. Should remove the background.
        """
    im = ImageEnhance.Contrast(img).enhance(0.9)
    im = ImageOps.grayscale(im)
    im = ImageOps.autocontrast(im, 100, 0)
    im = im.filter(ImageFilter.UnsharpMask(radius=2, percent=150, threshold=3))
    im = im.filter(ImageFilter.MinFilter(3))
    
    im_arr = np.array(im, dtype=np.uint8)
    im_mean = im_arr.mean()
    cut_off = im_mean - 1.9*(im_arr.max() - im_mean)
    im_bw = im_arr.astype(np.uint8)
    im_bw[im_bw>cut_off] = 255
    im_bw[im_bw<cut_off] = 0
    
    
    im_final = Image.fromarray(im_bw, mode='L')
    im_final = im_final.filter(ImageFilter.MedianFilter(size=5))
    im_final = im_final.filter(ImageFilter.ModeFilter(size=5))
#    im_final.show()
    
    return im_final


if __name__ == "__main__":
    # load image from command line
    import sys
    #if len(sys.argv) != 3:
        #print "usage: {} <image_file> <output_filename>".format(sys.argv[0])
    
    image_name = sys.argv[1]
    filename = sys.argv[2]
    img = Image.open(image_name)
    out = remove_background(img)
    out.save(filename)

