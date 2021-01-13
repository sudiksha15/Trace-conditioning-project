'''
Script to motion correct a several multipage .tif stacks using the Python Tif Motion Correction (ptmc) package

Requires ptmc, PIL and their dependencies
'''

from ptmc import io
from ptmc import parallel_pipelines as ppl
import numpy as np
import os
import multiprocessing as mp

if __name__ == "__main__":
    #Loading
    allFiles, filesDir = io.getFileList(GUItitle='Select All Tifs to Process')
    outDir = io.getDir(GUItitle='Select Directory to save Motion Corrected Tifs', initialDir=filesDir)
    
    #Start Parallel Pool
    n_cores = mp.cpu_count()
    pool = mp.Pool(processes=n_cores)
    
    #Refrence Frame info
    refMethod = io.askYesNo(GUItitle='Select a Pre-existing Reference?', GUImessage='Select a pre-existing reference image?  If "no" selected, one will be generated from the first selected file')
    if refMethod:
        refImage, refDir = io.loadImageStack(GUItitle='Select Homomorphic Filtered Reference .Tif for Motion Correction') #If need to select Ref Image
    else:
        #Make reference frame from first video
        refImage, rawRef = ppl.makeReferenceFrame(allFiles[0], saveDir=outDir, pool=pool, method='Median_Homomorphic') #To Generate Ref Image
    
    #Loop through all videos to correct and save output
    for tif in allFiles:
        ppl.correctImageStack(tif, refImage, saveDir=outDir, pool=pool, method='Median_Homomorphic')
    
    #Close Parallel Pool
    pool.close()

    #Send Save Directory to Standard Output
    print(outDir) #Print as stdout for use in bash scripting
