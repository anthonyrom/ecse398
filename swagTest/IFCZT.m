function x = IFCZT(y, N, W, A)
        % Fast Inverse Chirp-Z Transform in O(nlogn) time
        M = length(y);
        assert(M == N);
        x = complex(zeros(0, N), 0);
        for k = 0:(N-1)
            % Multiply P^(-1) and y
            x(:,k+1) = (W.^(-((k^2)/2))).*y(:,k+1);
        end
        % Precompute polynomial products
        p = complex(zeros(0, N), 0);
        p(:,1) = 1;
        for k = 1:(N-1)
            p(:,k+1) = p(:,k).*((W.^k)-1);
        end
        % Compute generating vector
        u = complex(zeros(0, N), 0);
        for k = 0:N-1
            u(:,k+1) = ((-1)^k)*((W.^((2*(k^2)-(2*N-1)*k+N*(N-1))/2))/(p(:,N-k).*p(:,k+1)));
        end
        [z, uHat, uTilde] = deal(complex(zeros(0, N), 0));
        for k = 1:(N-1)
            uHat(:,k+1) = u(:,N-k+1);
        end
        uHat(:,1) = 0;
        for k = 1:N
            z(:,k) = 0;
            uTilde(:,k) = 0;
        end
        uTilde(:,1) = u(:,1);
        xPrime = ToeplitzMultiplyE(uHat, z, x); % D
        xPrime = ToeplitzMultiplyE(z, uHat, xPrime); % D^T
        xDoublePrime = ToeplitzMultiplyE(u, uTilde, x); % A^T
        xDoublePrime = ToeplitzMultiplyE(uTilde, u, xDoublePrime); % A
        for k = 1:N
            % Subtract and divide by u_0
            x(:,k) = (xDoublePrime(k) - xPrime(k))/(u(:,1));
        end
        for k = 1:N
            % Multiply by A^(-1)Q^(-1)
            x(k) = (A.^(k-1))*(W.^(-((k-1)^2)/2))*x(k);
        end
    end