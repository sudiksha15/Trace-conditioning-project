'''
Code to perform and compare the timing between a serial version of code and a parallel version of code.

Created for PTMC serial vs. parallel testing
'''

#General Requirements
from ptmc import io
#Serial Requirements
from ptmc import pipelines as pl
#Parallel Requirements
from ptmc import parallel_pipelines as ppl
import multiprocessing as mp
#Timing Requirements
import timeit

#Get Input Values
allFiles, filesDir = io.getFileList(GUItitle='Select All Tifs to Process')
outDirSer = io.getDir(GUItitle='Select Directory to save Serial Motion Corrected Tifs', initialDir=filesDir)
outDirPar = io.getDir(GUItitle='Select Directory to save Parallel Motion Corrected Tifs', initialDir=filesDir)

#Set Up Functions for Timing
def serial(allFiles, outDir):
    refImage, rawRef = pl.makeReferenceFrame(allFiles[0], saveDir=outDir, method='Median_Homomorphic') #To Generate Ref Image
    #Loop through all videos to correct and save output
    for tif in allFiles:
        pl.correctImageStack(tif, refImage, saveDir=outDir, method='Median_Homomorphic')
        print('Completed ' + str(tif) + '\n')

def parallel(allFiles, outDir):
    #Start Parallel Pool
    n_cores = mp.cpu_count()
    pool = mp.Pool(processes=n_cores)
    refImage, rawRef = ppl.makeReferenceFrame(allFiles[0], saveDir=outDir, pool=pool, method='Median_Homomorphic') #To Generate Ref Image
    #Loop through all videos to correct and save output
    for tif in allFiles:
        ppl.correctImageStack(tif, refImage, saveDir=outDir, pool=pool, method='Median_Homomorphic')
        print('Completed ' + str(tif) + '\n')
    #Close Parallel Pool
    pool.close()

#Perform Timing
benchmarks = []

benchmarks.append(timeit.Timer('parallel(allFiles, outDirPar)', 'from __main__ import parallel, allFiles, outDirPar, ppl, mp').timeit(number=1))

print(benchmarks)

benchmarks.append(timeit.Timer('serial(allFiles, outDirSer)', 'from __main__ import serial, allFiles, outDirSer, pl').timeit(number=1))

print(benchmarks)

