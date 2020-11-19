fs = 48000; % Sampling frequency (samples per second) 
dt = 1/fs; % seconds per sample 
StopTime = 0.25; % seconds 
t = (0:dt:StopTime)'; % seconds 
F = 60; % Sine wave frequency (hertz) 
data = sin(2*pi*F*t);
 
slice = data(1:1024);
newslice = horzcat(slice, slice);

Mval = 1024; % samples per frame
A = 1;
W = (exp(-2*pi*1i/Mval));

res = FCZT(newslice, Mval, W, A);

inv = IFCZT(res, Mval, W, A);

resNew = vertcat(inv, inv).';
