function[r,it] = illinois(f, a, b, eps)
    
    % check bad input
    if(a == b)
        fprintf('Bad Input: x0 == x1');
        return; 
    end;
    
    fa = f(a);
    fb = f(b);
    it = 0;
    
    % check roots
    if(abs(fa) <= eps)
        r = a;
        return;
    end;
    
    if(abs(fb) <= eps)
        r = b;
        return;
    end;
    
    % check secant not horizontal
    if(fa == fb)
        fprintf('Bad Input: f(x0) == f(x1)');
        return;
    end;
    
    mu = 1;
    while(abs(fb) > eps && fb ~= 0 && fa ~= fb)
       it = it+1;
       
       % Illinois step
       c = b - (fb*((b-a)/(fb-mu*fa)));
       if(f(b)*f(c)<0)
           a=b;
           mu=1;
       else
           mu = mu/2;
       end;
       
       b=c;
       fa = f(a);
       fb = f(b);
    end;
    
    r = b;
end