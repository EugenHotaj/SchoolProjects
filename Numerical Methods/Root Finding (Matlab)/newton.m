function[r,it] = newton(f,df,x,eps)

    it=0;
    fx = f(x);
    dfx = df(x);
    
    % check root
    if(abs(fx) <= eps)
        r = x;
        return;
    end;
    
    while(abs(fx) > eps)
        it = it + 1;
        
        x = x - fx/dfx; % Newton Step 
        
        fx = f(x);
        dfx = df(x);
    end;
    
    r = x;
end