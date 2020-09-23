% Read in audio file:
filename = 'strummed_chords';
ext = '.flac'; % audio file extension

%   y : samples, double
%   Fs: sample rate, double
[y, Fs] = audioread(strcat('audio_samples/', filename, ext));

% Create time index (useful later)
% time: time of audio sample in seconds
tot_samples = size(y, 1); % total num. samples
seconds = tot_samples/Fs; % total length, seconds
time = linspace(0, tot_samples/Fs, tot_samples); 

% Playback original audio file
% sound(y, Fs)

% Time domain plot of original file
% timePlot(time, y)

% modulation: two approaches
freq = 8; % Hz

% manual approach
% output signal is z
carrier = zeros(size(y(:,1)));
z = zeros(size(y));
for i = 1:size(carrier) 
    % abs. value used so output sign is unchanged,
    % and the modulation affects only magnitude
    carrier(i) = sin(freq*2*pi*time(i));
    z(i, :) = carrier(i)*y(i, :);
end

% built-in way, overwrites above
% the two methods sound different (but similar)
w = zeros(size(y));
w = ammod(y, freq, Fs);

% z is created manually, w by ammod()
% this code shows they are not identical
identicalAM = isequal(z, w);
disp(identicalAM)

% ammod does suppressed carrier AM
% my manual method did not
% so the difference is having the carrier freq. in the output

% plot both vs original signal
fullPlot(time, y, z, w)

% play result
sound(w, Fs)

% Functions

function fullPlot(time, x, y, z)
    plot(time, x)
    hold on
    plot(time, y)
    hold on
    plot(time, z)
    hold off
end

function timePlot(time, x)
% Simple time domain plot of audio samples
    figure()
    clf
    plot(time, x)
end