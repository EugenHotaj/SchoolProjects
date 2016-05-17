function C = cfft(f,n)
    % Chebyshev coefficients of the interpolating polynomial
    % 
    % f = function
    % n = degree

    % get function values at cheb points
    A = zeros(n,1);
    for i=1:n
        A(i,1) = f(cos(i*pi/n));
    end

    % get full "circular" cheb values
    vals = [flipud(A) ; A(2:end-1)];
    
    % get fourier coefficients, discard imaginary part
    F = real(fft(vals)); 
    
    % get cheb coefficients
    C = flipud(F(1:n+1))/n;
    
    % divide 1st/last by 2
    C(1) = C(1)/2;
    C(end) = C(end)/2;
end