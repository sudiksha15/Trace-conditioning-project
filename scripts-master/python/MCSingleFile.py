'''
Script to motion correct a single multipage .tif stack using the Python Tif Motion Correction (ptmc) package

Requires ptmc, PIL and their dependencies
'''

from ptmc import io
from ptmc import processing as pro
from PIL import Image
import numpy as np

if __name__ == "__main__":
    #Full Processing without I/O takes (1288.67 sec, 21 min 29 sec)
    #Loading
    imgstack, fileparts = io.loadImageStack()
    #Processing Steps
    medstack = pro.doMedianFilter(imgstack, med_fsize=3)
    homomorphstack = pro.doHomomorphicFilter(medstack, sigmaVal=7)
    homoshift, yshift, xshift = pro.registerImages(homomorphstack)
    rawshift = pro.applyFrameShifts(imgstack, yshift, xshift)
    #Save Output
    io.saveFrameShifts(yshift, xshift, 
                    fileparts[0]+'/'+fileparts[1], 
                    fileparts[0]+'/'+fileparts[1][:-4]+'_frameShifts.hdf5')
    io.saveImageStack(homoshift, fileparts[0]+'/m_f_'+fileparts[1])
    io.saveImageStack(rawshift, fileparts[0]+'/m_'+fileparts[1])
    refIm = Image.fromarray(homoshift.mean(axis=0).astype(np.uint16))
    refIm.save(fileparts[0]+'/'+fileparts[1][:-4]+'_MCrefImage.tif')

