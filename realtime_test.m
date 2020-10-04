function realtime_test
%% AUDIO INPUT

% Choose input mode: either 'FILE' or 'DEVICE'
inputMode = 'FILE';
%   Then make sure to check/set the parameters for that input mode
%   in the AUDIO INPUT section.

% Number of samples to process with each loop iteration
% Note: If using ASIO, set output buffer size equal to this.
frameSize = 1024;

if strcmp(inputMode, 'FILE')
    % Input mode 'FILE' : read audio from file
    
    % Parameters
    fileName = 'strummed_chords.flac'; 
    file = strcat('audio_samples/', fileName);
    nPlays = 1; % Number of times to play file
    readRange = [1 inf]; % Range of samples to be read
    
    % Create audio source
    src = dsp.AudioFileReader(file, ...
        'PlayCount', nPlays, ...
        'SamplesPerFrame', frameSize, ...
        'ReadRange', readRange);

elseif strcmp(inputMode, 'DEVICE')
    % Input mode 'DEVICE' : read audio from device
    
    % Parameters
    sampleRate = 44100;
    inputDriver = 'ASIO'; % N/A for Mac/Linux
    inputDevice = 'Focusrite USB ASIO'; % List w/ getAudioDevices
    nChannels = 2; % Number of input channels
    chanMap = 2; % Which channel(s) to use
    
    % Create audio source
    src = audioDeviceReader(sampleRate, ...
        'Driver', inputDriver, ...
        'Device', inputDevice, ...
        'NumChannels', nChannels, ...
        'SamplesPerFrame', frameSize, ...
        'ChannelMappingSource', 'Property', ...
        'ChannelMapping', chanMap);
else
    % Input mode not valid/selected
    disp('Please set the input mode to either FILE or DEVICE')
end

%% AUDIO OUTPUT

% Parameters
outputDriver = 'ASIO'; % N/A for Mac/Linux
outputDevice = 'Focusrite USB ASIO'; % List w/ getAudioDevices
buffSize = frameSize; % Buffer size, must = frame size for ASIO

% Create audio sink
snk = audioDeviceWriter(...
    'Driver', outputDriver, ...
    'Device', outputDevice, ...
    'SampleRate', src.SampleRate, ...
    'SupportVariableSizeInput', true, ...
    'BufferSize', buffSize);

% This might be all that's needed for built-in soundcards:
% snk = audioDeviceWriter(src.SampleRate)

%% SCOPES + VISUALIZATION

% Oscilloscope
quickScope = timescope(...
    'SampleRate', src.SampleRate, ...
    'BufferLength', src.SampleRate*2*2, ...
    'YLimits', [-1, 1]);

% Spectrum Analyzer
quickSpec = dsp.SpectrumAnalyzer(...
    );

%% FX BLOCKS

% Reverb (from example)
reverb = reverberator(...
    'SampleRate', src.SampleRate, ...
    'PreDelay', 0, ...
    'WetDryMix', 0.4);

%% AUDIO STREAM LOOP

loopTime = 1; % (seconds), Used only for DEVICE mode

if strcmp(inputMode, 'FILE')
    while ~isDone(src)
        swag()
    end
elseif strcmp(inputMode, 'DEVICE')
    disp(strcat('Begin signal input... (', inputDevice, ...
        ", CH. ", num2str(chanMap), ')'))
    tic
    while toc < loopTime
        swag()
    end
    disp('End signal input.')
end

%% RELEASE OBJECTS

release(src)
release(snk)
release(reverb)
release(quickScope)

%% SPECTRAL WAVETABLE ANALOG/GUITAR ALGORITHM

    function swag()
        audio = src();
        reverbAudio = reverb(audio);
        snk(reverbAudio);
        % quickScope([audio, mean(reverbAudio, 2)])
    end

end