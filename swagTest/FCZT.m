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