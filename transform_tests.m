function transform_tests

% parameters that could be tunable
Mval = 256; % samples per frame
A = 1;
W = (exp(-2*pi*1i/Mval));
%W = nthroot(1.2, Mval)*exp((1i*2*pi)/Mval);
% could also choose between abs, real, or imag part of answer to play

% sampling rate has large effect on sound produced

% read first numframes frames of audio file
%[samples, Fs] = audioread('audio_samples/wonderwall_48k_32bit.flac');
[samples, Fs] = audioread('192k/one.wav');

numFrames = length(samples)/Mval;

outSamples = zeros(size(samples));
for jaj = 1:Mval:(numFrames*Mval - Mval)
    trans = FCZT(samples(jaj:jaj+Mval-1), Mval, W, A);
    inv = IFCZT(trans, Mval, W, A);
    outSamples(jaj:jaj+Mval-1) = inv;
end

% playback audio
soundsc(abs(outSamples), Fs);
%soundsc(real(outSamples), Fs);
%soundsc(imag(outSamples), Fs);

    function y = FCZT(x, M, W, A)
        % Chirp-Z Transform in O(nlogn) time
        % x : samples, length N
        % M : size of output vector
        % A, W : complex numbers, parameters to define logarithmic
        %        spiral contour and location of samples on it.
        N = size(x);
        [y, r] = deal(zeros(N));
        c = double.empty(0, M);
        for k = 1:N
            y(k) = (W.^(((k-1)^2)/2))*(A.^(-(k-1)))*x(k);
            r(k) = W.^(-((k-1)^2)/2);
        end
        for k = 1:M
            c(k) = W.^(-((k-1)^2)/2);
        end
        y = ToeplitzMultiplyE(r, c, y);
        for k = 1:M
            y(k) = (W.^(-((k-1)^2)/2))*y(k);
        end
    end

    function x = IFCZT(y, N, W, A)
        % Fast Inverse Chirp-Z Transform in O(nlogn) time
        M = length(y);
        assert(M == N);
        n = N;
        x = zeros(0, n);
        for k = 0:(n-1)
            % Multiply P^(-1) and y
            x(k+1) = (W.^(-((k^2)/2)))*y(k+1);
        end
        % Precompute polynomial products
        p = double.empty(0, n);
        p(1) = 1;
        for k = 1:(n-1)
            p(k+1) = p(k)*((W.^k)-1);
        end
        % Compute generating vector
        u = double.empty(0, n);
        for k = 0:n-1
            u(k+1) = ((-1)^k)*((W.^((2*(k^2)-(2*n-1)*k+n*(n-1))/2))/(p(n-k)*p(k+1)));
        end
        [z, uHat, uTilde] = deal(double.empty(0, n));
        uHat(1) = 0;
        for k = 1:(n-1)
            uHat(k+1) = u(n-k+1);
        end
        for k = 1:n
            z(k) = 0;
            uTilde(k) = 0;
        end
        uTilde(1) = u(1);
        xPrime = ToeplitzMultiplyE(uHat, z, x); % D
        xPrime = ToeplitzMultiplyE(z, uHat, xPrime); % D^T
        xDoublePrime = ToeplitzMultiplyE(u, uTilde, x); % A^T
        xDoublePrime = ToeplitzMultiplyE(uTilde, u, xDoublePrime); % A
        for k = 1:n
            % Subtract and divide by u_0
            x(k) = (xDoublePrime(k) - xPrime(k))/(u(1));
        end
        for k = 1:n
            % Multiply by A^(-1)Q^(-1)
            x(k) = (A.^(k-1))*(W.^(-((k-1)^2)/2))*x(k);
        end
    end

    function y = ToeplitzMultiplyE(r, c, x)
        % Compute the product y = Tx of a Toeplitz matrix T
        % and a vector x, where T is specified by its first row
        % r = (r(1), r(2), ... r(N)) and its first column
        % c = (c(1), c(2), ... c(M)), where r(1) = c(1).
        N = length(r);
        M = length(c);
        assert(c(1) == r(1));
        assert(length(x) == N);
        n = int32(2^(log2(M+N-1)));
        % Form an array cHat by concatenating c, n-(M+N-1)
        % zeros, and the reverse of the last N-1 elements of r.
        cHat = double.empty(0, n);
        for k = 1:M
            cHat(k) = c(k);
        end
        for k = 1:N
            cHat(n-k+1) = r(k);
        end
        % cHat = (c(1), c(2), ... c(M), 0, ..., 0, r(N), ... r(3), r(2))
        xHat = ZeroPad(x, n);
        yHat = CirculantMultiply(cHat, xHat);
        % The result is the first M elements of yHat
        y = double.empty(0, M);
        for k = 1:M
            y(k) = yHat(k);
        end
    end

    function xHat = ZeroPad(x, n)
        % Pad an array to length n by appending zeros
        m = length(x);
        assert(m <= n);
        xHat = double.empty(0, n);
        for k = 1:m
            xHat(k) = x(k);
        end
        for k = (m+1):n
            xHat(k) = 0;
        end
    end

    function y = CirculantMultiply(c, x)
        % Compute the product y = Gx of a circulant matrix G
        % and a vector x, where G is generated by its first column
        % c = (c(1), c(2), ..., c(n)).
        % Runs in O(nlogn) time
        n = length(c);
        assert(length(x) == n);
        C = fft(c);
        X = fft(x);
        Y = double.empty(0, n);
        for k = 1:n
            Y(k) = C(k)*X(k);
        end
        y = ifft(Y);
    end
end