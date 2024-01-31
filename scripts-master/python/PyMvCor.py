"""
Code to do movement correction for a single .tif file, but intended to be run in parallel

@author: kyleh
"""

#Import packages
import numpy as np
from numpy.fft import fft2, ifft2, fftshift
from scipy.ndimage import median_filter, gaussian_filter, shift
import os
import Tkinter as tk
import tkFileDialog as tkfd
import tifffile as tf #Much faster loading but can't save large tiffs (Only as BigTiff)
from PIL import Image #Slower loading, but can save large tiffs
import h5py

def loadImageStack():
    #Get File Input
    root = tk.Tk(); #Graphical Interface
    root.withdraw()
    tif_file = tkfd.askopenfilename(title='Select .Tif')
    fileparts = os.path.split(tif_file)

    #Load File (Takes 191 sec. 2.5 sec locally)
    imgstack = tf.imread(tif_file)
    
    #PIL (18.3 sec locally)
    #tiffstack = Image.open(tif_file)
    #imgs1 = np.zeros((tiffstack.n_frames, tiffstack.height, tiffstack.width))
    #for idx in range(tiffstack.n_frames):
    #    try:
    #        tiffstack.seek(idx)
    #        imgs1[idx,...] = tiffstack
    #    except EOFError:
    #        #Not enough frames in img
    #        break
    
    return imgstack, fileparts

def doMedianFilter(imgstack, med_fsize=3):
    #Median Filter Portion (Takes 303.37 sec, 5 min 3 sec)
    
    #med_fsize is the median filter size
    medstack = np.empty(imgstack.shape, dtype=np.uint16)
    for idx, frame in enumerate(imgstack):
        medstack[idx,...] = median_filter(frame, size=med_fsize)
        
    return medstack

def doHomomorphicFilter(imgstack, sigmaVal=7):
    ##Homomorphic Filter (Takes 323.1 sec, 5 min 23 sec)
    #imgstack is (nframes, height, width) numpy array of images
    #sigmaVal is the gaussian_filter size for subtracing the low frequency component
    # Constants to scale from between 0 and 1
    eps = 7./3 - 4./3 -1 
    maxval = imgstack.max()
    ScaleFactor = 1./maxval
    Baseline = imgstack.min()

    # Subtract minimum baseline, and multiply by scale factor.  Force minimum of eps before taking log.
    logimgs = np.log1p(np.maximum((imgstack-Baseline)*ScaleFactor, eps))

    # Get Low Frequency Component from Gaussian Filter
    lpComponent = np.empty(logimgs.shape)
    for idx, frame in enumerate(logimgs):
        lpComponent[idx,...] = gaussian_filter(frame, sigma=sigmaVal)

    # Remove Low Frequency Component and Shift Values
    adjimgs = logimgs - lpComponent
    logmin = adjimgs.min()
    adjimgs = adjimgs - logmin #Shift by minimum logged difference value, so lowest value is 0

    #Undo the log and shift back to standard image space
    homomorphimgs = (np.expm1(adjimgs)/ScaleFactor) + Baseline
    
    return homomorphimgs

def calculateCrossCorrelation(imgstack, Ref=None):
    #Perform frame-by-frame Image Registration using Cross Correlation (465.43 sec. 7 min 45 sec)
    #imgstack is (nframes, height, width) numpy array of images
    #Precalculate Static Values
    if Ref is None:
        Ref = imgstack.mean(axis=0)
    imshape = Ref.shape
    nframes = imgstack.shape[0]
    imcenter = np.array(imshape)/2
    yshift = np.empty((nframes,1)); xshift = np.empty((nframes,1));
    Ref_fft = fft2(Ref).conjugate()
    
    #Measure shifts from Images and apply those shifts to the Images
    stackshift = np.zeros_like(imgstack, dtype=np.uint16)
    for idx, frame in enumerate(imgstack):
        xcfft = fft2(frame) * Ref_fft
        xcim = abs(ifft2(xcfft))
        xcpeak = np.array(np.unravel_index(np.argmax(fftshift(xcim)), imshape))
        disps = imcenter - xcpeak
        stackshift[idx,...] = np.uint16(shift(frame, disps))
        yshift[idx] = disps[0]
        xshift[idx] = disps[1]
    
    return stackshift, yshift, xshift

def applyFrameShifts(imgstack, yshift, xshift):
    #Apply frame shifts to each frame of an image stack (301.28 sec.  5 min 2 sec)
    #imgstack is (nframes, height, width) numpy array of images
    #yshift is the number of pixels to shift each frame in the y-direction (height)
    #xshift is the number of pixels to shift each frame in the x-direction (width)
    #Precalculate Static Values
    stackshift = np.zeros_like(imgstack, dtype=np.uint16)
    for idx, frame in enumerate(imgstack):
        stackshift[idx,...] = np.uint16(shift(frame, (yshift[idx],xshift[idx])))
    
    return stackshift

def saveImageStack(imgstack, outname):
    #Save numpy array as multipage tiff file (203.50 sec.  3 min 24 sec)
    #imgstack is (nframes, height, width) numpy array of images to save
    #outname is the path & filename to save the file out
    imlist = []
    for frame in imgstack:
        imlist.append(Image.fromarray(frame))
    
    imlist[0].save(outname, save_all=True, append_images=imlist[1:])

def saveFrameShifts(yshift, xshift, shiftsfile, outname):
    #Save numpy array of yshifts and xshifts as HDF5 File
    #yshift is the number of pixels to shift each frame in the y-direction (height)
    #xshift is the number of pixels to shift each frame in the x-direction (width)
    #shiftsfile is the name of the file that the shifts are for (Raw Data File)
    #outname is the path & filename to save the file out
    f = h5py.File(outname)
    f.create_dataset('filename', data=shiftsfile)
    f.create_dataset('yshift', data=yshift)
    f.create_dataset('xshift', data=xshift)

def main():
    #Full processing without I/O takes (1288.67 sec, 21 min 29 sec)
    #Loading
    imgstack, fileparts = loadImageStack()
    #Processing Steps
    medstack = doMedianFilter(imgstack, med_fsize=3)
    homomorphstack = doHomomorphicFilter(medstack, sigmaVal=7)
    homoshift, yshift, xshift = calculateCrossCorrelation(homomorphstack)
    rawshift = applyFrameShifts(imgstack, yshift, xshift)
    #Save Output
    saveFrameShifts(yshift, xshift, 
                    fileparts[0]+'/'+fileparts[1], 
                    fileparts[0]+'/'+fileparts[1][:-4]+'_frameShifts.hdf5')
    saveImageStack(homoshift, fileparts[0]+'/m_f_'+fileparts[1])
    saveImageStack(rawshift, fileparts[0]+'/m_'+fileparts[1])
    refIm = Image.fromarray(homoshift.mean(axis=0).astype(np.uint16))
    refIm.save(fileparts[0]+'/'+fileparts[1][:-4]+'_MCrefImage.tif')

main()
