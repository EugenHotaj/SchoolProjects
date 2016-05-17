function[L] = inverse_iteration(A)
    
    if(~issymetric(A))
        error('Matrix must be symmetric.');
    end

    eps = 10^-6;
    l = sturm(hh_tridiag(A));
    n = length(l);
    maxit = 20;
    
    L = zeros(n);

    for i=1:n
       val = l(i);
       vec0 = zeros(n,1);
       vec1 = ones(n,1);
       it = 0;
       while(norm(abs(vec0-vec1))>eps && it < maxit)
           vec0 = vec1;
           w = (A-eye(n)*val) \ vec0;
           vec1 = 1/norm(w)*w;
           it = it + 1;
       end
       L(:,i) = vec1;
    end
end