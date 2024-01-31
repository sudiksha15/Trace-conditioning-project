#!/bin/bash

# Mount the File Directory
#mount /mnt/eng_research_handata
#sleep 5 #Pause for 5 seconds, hopefully help with any delays for commands

# Do Behavior Data First Since It's Shortest
#date
#matlab -r "addpath('~/gitclones/scripts/matlab/behavior/'); cd '~/gitclones/scripts/matlab/behavior/'; run behaviorExtraction.m"

# Do Motion Correction
date
source activate gittesting #motionPipeline - Robb's Login #gittesting - Kyle's Login
MCDIR=$(python ~/gitclones/scripts/python/MCMultiFilesParallel.py | tail -n 1)
#source deactivate

#Use for Subbed Motion Correction to not re-run
#cd ../
#MCDIR=$(python ~/gitclones/scripts/bash/location_echo.py | tail -n 1)

# Change to Motion Correction Location
cd "$MCDIR"
echo "$MCDIR"

# Create Composite Image for ACSAT Algorithm
date
matlab -softwareopengl -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"

# Run ACSAT
#date
#matlab -softwareopengl -r "addpath('~/gitclones/scripts/matlab/rois/', '~/gitclones/acsat/'); run autorun_ACSAT.m; exit"

# Run Trace Extraction
#date
#matlab -softwareopengl -r "addpath('~/gitclones/scripts/matlab/traces/'); run pwdExtractTraces.m; exit"

# Run Making Plots
#date
#matlab -softwareopengl -r "addpath('~/gitclones/scripts/matlab/plots/'); run pwdSciReportsPlots.m; exit"
