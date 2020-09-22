% Read in audio file:
%   y : samples, double
%   Fs: sample rate, double
[y, Fs] = audioread('audio_samples/strummed_chords.flac');

% Playback audio file
sound(y, Fs)

% Time domain plot of signal
timePlot(y)

% Functions

function timePlot(x)
% Simple time domain plot of audio samples
    figure()
    clf
    plot(x)
end