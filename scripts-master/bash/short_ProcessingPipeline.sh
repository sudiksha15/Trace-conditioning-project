#!/bin/bash

# Determine Folder
MCDIR=$(python ~/gitclones/scripts/bash/location_echo.py | tail -n 1)

# Change to Motion Correction Location
cd "$MCDIR"
echo "$MCDIR"

# Run ACSAT
date
matlab -r "addpath('~/gitclones/scripts/matlab/rois/', '~/gitclones/acsat/'); run autorun_ACSAT.m; exit"

# Run Trace Extraction
date
matlab -r "addpath('~/gitclones/scripts/matlab/traces/'); run pwdExtractTraces.m; exit"

# Run Making Plots
date
matlab -r "addpath('~/gitclones/scripts/matlab/plots/'); run pwdSciReportsPlots.m; exit"
