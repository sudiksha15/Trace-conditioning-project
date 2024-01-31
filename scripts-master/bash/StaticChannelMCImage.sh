#!/bin/bash

# Do Motion Correction
date
source activate gittesting #motionPipeline - Robb's Login #gittesting - Kyle's Login
MCDIR=$(python ~/gitclones/scripts/python/MCMultiFilesParallel.py | tail -n 1)
source deactivate

# Change to Motion Correction Location
cd "$MCDIR"
echo "$MCDIR"

# Create Composite Image
date
matlab -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"

