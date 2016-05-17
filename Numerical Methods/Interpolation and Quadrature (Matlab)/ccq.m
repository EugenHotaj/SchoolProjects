function r = ccq(f,n)
    %CCQ finds the integral of f from -1 to +1 using Clenshaw-Curtis quadrature

    % get coefficients
    B = cfft(f,n);
    
    % find integral
    r = 0;
    for i=2:2:n
        r = r + B(i-1)*2/(1-i^2);
    end
end

