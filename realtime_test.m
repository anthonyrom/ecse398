% Read in audio file as 'real time' input
file = 'strummed_chords';
fileName = strcat('audio_samples/', file, '.flac');

% Options/defaults for AFR
plays = 1; % number times to play file
frameSize = 1024; % samples per frame
readRange = [1 inf]; % range of samples to read

% Create AFR object
afr = dsp.AudioFileReader(fileName, 'PlayCount', plays, ...
    'SamplesPerFrame', frameSize, 'ReadRange', readRange);

% Options/defaults for ADW
driver = 'ASIO'; % 'DirectSound' or 'ASIO', probably (windows only!)
adwDev = 'Default'; % Device used for playback

% Create ADW object for playback
adw = audioDeviceWriter('SampleRate', afr.SampleRate);

% THE LOOP
while ~isDone(afr)
    audio = afr(); % load frame (col. vector of samples)
    adw(audio); % playback audio
end

release(afr);
release(adw);