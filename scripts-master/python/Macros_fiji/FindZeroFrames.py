from ij import WindowManager
from ij.gui import WaitForUserDialog

plotWindow = WindowManager.getActiveWindow()
X = plotWindow.getXValues()
Y = plotWindow.getYValues()
zeroY = [int(idx) for idx, val in enumerate(Y) if (val==0)]
print(zeroY)

labelWindow = WindowManager.getWindow("Label Edition")
labelWindow.toFront()

for idx, zeroFrame in enumerate(zeroY):
	labelWindow.showSlice(zeroFrame)
	WaitForUserDialog('Frame # {} ({} out of {})'.format(zeroFrame, idx, len(zeroY))).show()
print("Completed All Frames")