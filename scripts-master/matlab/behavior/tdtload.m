function [frames, puffs, sounds, tankPath] = tdtload(startDir)
%Function to load Registered TDT Tanks
%Written by Kyle Hansen Sept 2017
%TDT software requires ActiveX controls, so this will only work on a
%Windows machine with the TDT software correctly installed.
%All Tanks must be pre-registered using the Scope program as a part of the 
%OpenEx software package provided by Tucker Davis Technologies (TDT) before
%this script will work in loading them.
%The tank is the High Level File Directory that on Windows Explorer shows
%up with a purple line under a blue tank thing, as the icon for the
%directory

%startDir - Input as directory to start for selection of TDT Tank
%frames - Output assumed at 1 kHz of square wave for 5 ms pulse when
%imaging frame is occuring
%puffs - Output at 1 kHz of square wave pulse for when the puff is on
%sounds - Output at 1 kHz of square wave pulse when the sound is on.  Empty
%for experiments where sound wasn't recorded.

%Find and load Data Tanks
tankPath = uigetdir(startDir,'Select Data Tank Directory');
blockPath = uigetdir(tankPath,'Select Data Tank Block Directory');

%New TDT Loading
TTL_data = TDTbin2mat(blockPath, 'TYPE', {'epocs'});
FrameStream = TDTbin2mat(blockPath, 'TYPE', {'streams'}, 'STORE', 'Puls');
PuffStream = TDTbin2mat(blockPath, 'Type', {'streams'}, 'STORE', 'Eyes');
SoundStream = TDTbin2mat(blockPath, 'TYPE', {'streams'}, 'STORE', 'Soun');

%Timing
timing_val = TTL_data.epocs.Tick.data; %TTL Pulses

%Frames
frames_TS = TTL_data.epocs.Valu.onset; %TTL Pulses
frames = FrameStream.streams.Puls.data';

%Puffs
%puffs_TS = TTL_data.epocs.Eval.onset; %TTL Pulses
puffs = PuffStream.streams.Eyes.data';

%Sounds
sounds = SoundStream.streams.Soun.data';

% ---- No longer using this code, since just using analog stream data --- %
% %Reformat frames & puffs for extraction from TTL Pulses
% %Sample Timing
% samp_diff = 0.001; %Assume 1kHz sampling rate for TTL output values.
% timing = [timing_val(1):samp_diff:timing_val(end)]';
% 
% %Populate Frame Trace
% frame_on = frames_TS(1:2:end);
% frame_off = frames_TS(2:2:end);
% frames = false(numel(timing),1);
% for idx = 1:numel(frame_on)
%     frOn = frame_on(idx);
%     frOff = frame_off(idx);
%     frames = frames | ((timing >= frOn) & (timing <= frOff));
% end
% 
% %Populate Puff Trace
% puff_on = puffs_TS(1:2:end);
% puff_off = puffs_TS(2:2:end);
% puffs = false(numel(timing),1);
% for idx = 1:numel(puff_on)
%     pfOn = puff_on(idx);
%     pfOff = puff_off(idx);
%     puffs = puffs | ((timing >= pfOn) & (timing <= pfOff));
% end

end