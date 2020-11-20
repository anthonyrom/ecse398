function y = CirculantMultiply(c, x)
        % Compute the product y = Gx of a circulant matrix G
        % and a vector x, where G is generated by its first column
        % c = (c(1), c(2), ..., c(n)).
        % Runs in O(nlogn) time
        n = length(c);
        assert(length(x) == n);
        C = fft(c);
        X = fft(x);
        Y = zeros(0, n);
        for k = 1:n
            Y(k) = C(k)*X(k);
        end
        y = ifft(Y);
    end