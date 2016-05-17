function[e,l] = fib(n)
    f(1)=1;
    f(2)=1;
    for i=2:(n-1)
        f(i+1) = f(i) + f(i-1);
    end
    
    l=f(n-1);
    
    g(n)=f(n);
    g(n-1)=f(n-1);
    for i=(n-1):-1:2
        g(i-1)=g(i+1) - g(i);
    end
    
    e = g(1);
end