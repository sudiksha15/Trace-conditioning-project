function behavior2hdf5(binSounds, binPuffs, binTrials, eye_trace, pupil_trace, filename)
    %Code to take a binary behavior traces as input and save it's output 
    %as an hdf5 file all ready created with traces.  
    
    %binSounds - Binary trace of times when the sound is on
    %binPuffs - Binary trace of times when the puff is on
    %binTrials - Trace of trial extents.  Identity is 1 if the mouse moved
    %during the trial.  Identity is -1 if the mouse didn't move during the
    %trial.
    %eye_trace - Sum of binarized video frames tracking the whole eye area.
    %Input as empty [] if not using this for behavior.
    %pupil_trace - Sum of binarized video frames tracking just pupil area.
    %Input as empty [] if not using this for behavior.
    %filename - String as filename to save hdf5 as.  The extensions .hdf5
    %should be included
    
    %Hidden output - hdf5 file saved as filename
    
    %Add Sounds to HDF5
    h5create(filename, '/binSounds', size(binSounds));
    h5write(filename, '/binSounds', double(binSounds));
    descString = 'Binary trace of times when the sound is on (1), but 0 elsewhere';
    h5writeatt(filename, '/binSounds', 'Description', descString);
    
    %Add Puffs to HDF5
    h5create(filename, '/binPuffs', size(binPuffs));
    h5write(filename, '/binPuffs', double(binPuffs));
    descString = 'Binary trace of times when the puff is on (1), but 0 elsewhere';
    h5writeatt(filename, '/binPuffs', 'Description', descString);
    
    %Add Trials to HDF5
    h5create(filename, '/binTrials', size(binTrials));
    h5write(filename, '/binTrials', binTrials);
    descString = ['Trace of trial extents.  Identity is 1 if the mouse moved ' ...
        'during the trial.  Identity is -1 if the mouse did not move during the trial.' ...
        'If Binary Eye Movies Used, should all be 1s and scoring can be done from eyeTrace.'];
    h5writeatt(filename, '/binTrials', 'Description', descString);
    
    %Add Eye Trace to HDF5
    if ~isempty(eye_trace)
        h5create(filename, '/eyeTrace', size(eye_trace));
        h5write(filename, '/eyeTrace', eye_trace);
        descString = ['Trace of binarized eye video.  Value is sum of pixels for each frame '...
            'in the eye video.  eyeTrace sought to binarize the whole area of the eye.'];
        h5writeatt(filename, '/eyeTrace', 'Description', descString);
    end
    
    %Add Pupil Trace to HDF5
%     if ~isempty(pupil_trace)
%         h5create(filename, '/pupilTrace', size(pupil_trace));
%         h5write(filename, '/pupilTrace', pupil_trace);
%         descString = ['Trace of binarized eye video.  Value is sum of pixels for each frame '...
%             'in the eye video.  pupilTrace sought to binarize just the pupil area of the eye.'];
%         h5writeatt(filename, '/pupilTrace', 'Description', descString);
%     end

end
