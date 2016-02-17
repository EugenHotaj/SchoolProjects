function[r,it] = newton(f,df,x,eps)
    
    % check root
    fx = f(x);
    if(abs(fx) <= eps)
        r = x;
        return;
    end;
    
    it=0;
    dfx = df(x);
    
    while(abs(fx) > eps)
        it = it + 1;
        
        x = x - fx/dfx; % Newton Step 
    
        fx = f(x);
        dfx = df(x);
    end;
    
    r = x;
end