import numpy as np
from ptmc import io
import cv2

fileList, fileDir = io.getFileList()

outList = []
for imgFile in fileList:
    tempStack, imgDir = io.loadImageStack(imgFile)
    tempStack8 = (tempStack * (2.**8/2.**16)).astype(np.uint8)
    outList.append(tempStack8)

outStack = np.concatenate(outList)
del outList #Clear Memory

nframes, height, width = outStack.shape

fps = 240

aviName = fileDir.split('/')[-1]+'_AllVids.avi'

aviPath = fileDir + '/' + aviName

out = cv2.VideoWriter(aviPath,cv2.VideoWriter_fourcc(*'MPEG'), fps, (width, height), isColor=False)

for frame in outStack:
     out.write(frame)

out.release()
