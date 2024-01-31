#!/bin/bash

#Change to Directory and Run Image Projection
DIR1=$"/mnt/eng_research_handata/Kyle/AliEyeBlink/ali24_d5_s1"
cd $DIR1
date
matlab -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"

#Change to Directory and Run Image Projection
DIR2=$"/mnt/eng_research_handata/Kyle/AliEyeBlink/ali24_d5_s2"
cd $DIR2
date
matlab -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"

#Change to Directory and Run Image Projection
DIR3=$"/mnt/eng_research_handata/Kyle/AliEyeBlink/ali25_d5_s2"
cd $DIR3
date
matlab -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"

#Change to Directory and Run Image Projection
DIR4=$"/mnt/eng_research_handata/Kyle/AliEyeBlink/ali26_d5_s1"
cd $DIR4
date
matlab -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"

#Change to Directory and Run Image Projection
DIR5=$"/mnt/eng_research_handata/Kyle/AliEyeBlink/ali26_d5_s2"
cd $DIR5
date
matlab -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"

#Change to Directory and Run Image Projection
DIR6=$"/mnt/eng_research_handata/Kyle/AliEyeBlink/ali26_d2_s1"
cd $DIR6
date
matlab -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"

#Change to Directory and Run Image Projection
DIR7=$"/mnt/eng_research_handata/Kyle/AliEyeBlink/ali25_d2_s1"
cd $DIR7
date
matlab -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"

#Change to Directory and Run Image Projection
DIR8=$"/mnt/eng_research_handata/Kyle/AliEyeBlink/ali24_d2_s1"
cd $DIR8
date
matlab -r "addpath('~/gitclones/scripts/matlab/rois/'); run image_projection(pwd); exit"
