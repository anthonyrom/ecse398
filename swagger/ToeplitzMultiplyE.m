function y = ToeplitzMultiplyE(r, c, x)
    % Compute the product y = Tx of a Toeplitz matrix T
    % and a vector x, where T is specified by its first row
    % r = (r(1), r(2), ... r(N)) and its first column
    % c = (c(1), c(2), ... c(M)), where r(1) = c(1).
    N = length(r);
    M = length(c);
    assert(real(c(1)) == real(r(1)));
    assert(length(x) == N);
    n = int32(2^(log2(M+N-1)));
    % Form an array cHat by concatenating c, n-(M+N-1)
    % zeros, and the reverse of the last N-1 elements of r.
    cHat = complex(zeros(1, n), 0);
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
    y = complex(zeros(1, M),0);
    for k = 1:M
        y(k) = yHat(k);
    end
end