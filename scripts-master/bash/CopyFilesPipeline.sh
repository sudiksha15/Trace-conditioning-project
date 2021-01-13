#!/bin/bash

# Select Directory to Copy From (REMOTEDIR) and Copy To (LOCALDIR)
REMOTEDIR=$"/mnt/eng_research_handata/eng_research_handata2/Kyle/TonePuff-Rebecca/2982/2982_d1_s1" #"/mnt/eng_research_handata/eng_research_handata2/Rebecca/Autism/2089/Day_1/Ball" #"/mnt/eng_research_handata/Kyle/AliEyeBlink/ali25_d5_s1"
LOCALDIR=$"/mnt/HD_6TB/Kyle/CopyProcessing_Rebecca/2982/2982_d1_s1_First"

# Find motion corrected filtered (m_f_) files to copy
echo $"Copying Files from "$REMOTEDIR
find $REMOTEDIR -name "2982*).tif" -exec cp {} $LOCALDIR \;

# Move to LOCALDIR and Execute Matlab Script
#cd $LOCALDIR
#date
#matlab -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"

# Move Output to Server
#find $LOCALDIR -name "*.fig" -exec cp {} $REMOTEDIR \;
#find $LOCALDIR -name "*.fig" -exec rm {} \;

# Remove motion corrected filtered (m_f_) files from local machine
#echo $"Removing files from local machine at "$LOCALDIR
#find $LOCALDIR -name "m_f_*" -exec rm {} \;
