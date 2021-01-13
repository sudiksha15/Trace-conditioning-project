from ij import WindowManager

plotWindow = WindowManager.getActiveWindow()
X = plotWindow.getXValues()
Y = plotWindow.getYValues()
uniqueY = list(set(Y))
intY = sorted([int(num) for num in uniqueY if (num-int(num))==0])
print(intY)