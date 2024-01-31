from ij import IJ, ImagePlus
from ij.gui import Plot
import timeit

#Get Active Image
act_image = IJ.getImage()
stack = act_image.getImageStack()

#ROI Info and Cropping
roi = act_image.getRoi()
x_val = int(roi.getXBase())
y_val = int(roi.getYBase())
width = int(roi.getFloatWidth())
height = int(roi.getFloatHeight())
NSlices = stack.getSize()

#Crop to ROI Size
stack_crop = stack.crop(x_val, y_val, 0, width, height, NSlices)

time1 = timeit.default_timer()
print roi
print stack
print stack_crop

modal_vals = []

for idx in range(0, stack_crop.size()):
  #Determine Mode of each Slice
  sel_frame = stack_crop.getProcessor(idx+1) #1-based indexing
  frame_hist = sel_frame.getHistogram()
  hist_set = sorted(set(frame_hist))
  modal_count = hist_set[-1]
  modal_val = frame_hist.index(modal_count)
  if modal_val == 0:
    modal_count = hist_set[-2]
    modal_val = frame_hist.index(modal_count)
  modal_vals.append(modal_val)
  if idx%1000 == 0:
    print (idx, timeit.default_timer() - time1)

print sorted(set(modal_vals))
print timeit.default_timer() - time1

final_plot = Plot("Modal Values", "Stack", "Value")
final_plot.add("line", modal_vals)
final_plot.show()

print timeit.default_timer() - time1