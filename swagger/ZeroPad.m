function xHat = ZeroPad(x, n)
    % Pad an array to length n by appending zeros
    m = length(x);
    assert(m <= n);
    xHat = complex(zeros(1, n), 0);
    for k = 1:m
        xHat(k) = x(k);
    end
    for k = (m+1):n
        xHat(k) = 0;
    end
end