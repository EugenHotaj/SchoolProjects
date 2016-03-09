function[l] = eigenvalues(A)
    if(~issymmetric(A))
        error('Matrix must be symmetri');
    end
    
    l = sturm(hh_tridiag(A));
end