function [x] = tridiag(L,D,U,B,n)
% TRIDIAG tridiagonal matrix solver
    
    x = zeros(n,1);
    gamma = zeros(n,1);

    beta = D(1);
    x(1) = B(1)/beta;

    % Start the decomposition and forward substitution
    for j = 2:n
        gamma(j) = U(j-1)/beta ;
        beta = D(j)-L(j)*gamma(j) ;

        x(j) = (B(j)-L(j)*x(j-1))/beta;
    end

    % Perform the backsubstitution
    for j = 1:(n-1)
        k = n-j ;
        x(k) = x(k) - gamma(k+1)*x(k+1);
    end
end