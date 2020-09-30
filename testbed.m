% Read in audio file:
filename = 'slide_bend_vibrato';
ext = '.flac'; % audio file extension

%   y : samples, double
%   Fs: sampling frequency, double
[y, Fs] = audioread(strcat('audio_samples/', filename, ext));

% Useful stuff
T = 1/Fs; % sampling period
L = length(y); % number of samples
time = (0:L-1)*T; % time values for each sample

% Play back original audio file
% sound(y, Fs)

% Time domain plot of original file
% timePlot(time, y)

% amplitude/intermodulation: two approaches
freq = 300; % Hz

% manual approach
% output signal is z
carrier = zeros(size(y));
z = zeros(size(y));
for i = 1:L
    % abs. value used so output sign is unchanged,
    % and the modulation affects only magnitude
    carrier(i) = sin(freq*2*pi*time(i));
    z(i, :) = carrier(i)*y(i, :);
end

% built-in way
% output signal is w
% the two methods sound different (but similar)
w = ammod(y, freq, Fs);

% z is created manually, w by ammod()
% this code shows they are not identical
identicalAM = isequal(z, w);
% disp(identicalAM)

% ammod does suppressed carrier AM (DSB-SC)
% my manual method did not (DSBAM)
% so the difference is having the carrier freq. in the output

% compare a few versions of intermodulation
test1 = ammod(y, 5, Fs);
test2 = ammod(y, 200, Fs);
test3 = ammod(y, 1000, Fs);

% plot various IM versions
fullPlot(time, test1(:,1), test2(:,1), test3(:,1))

% play result
% sound(w, Fs)

% Functions

function fullPlot(time, x, y, z)
    plot(time, x, time, y, time, z)
    title('Intermodulated Signals with Various Carrier Frequencies')
    xlabel('Time (s)')
    ylabel('Normalized Audio Amplitude')
    legend({'f = 5 Hz', 'f = 200 Hz', 'f = 1000 Hz'})
    xlim([0.2 0.3])
end

function timePlot(time, x)
% Simple time domain plot of audio samples
    plot(time, x)
    title('Original Audio Signal vs. Time')
    xlabel('Time (s)')
    ylabel('Normalized Audio Amplitude')
    legend({'Audio Signal'})
    xlim([0 0.5])
end