% Read in audio file:
%   y : samples, double
%   Fs: sample rate, double
[y, Fs] = audioread('audio_samples/strummed_chords.flac');

% Playback audio file
%sound(y, Fs)

%timePlot(y)



% Functions

function timePlot(x)
% Simple time domain plot of audio samples
    figure()
    clf
    plot(x)
end

function audioTrunc(N, x, Fs)
% truncate audio
%   N : length of output in seconds
%   x : input audio samples
%   Fs : sample rate of input audio
    len_samples = N*Fs
end