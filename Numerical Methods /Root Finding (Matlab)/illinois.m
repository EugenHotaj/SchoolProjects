function[r,it] = illinois(f, a, b, eps)
    
    it=0;
    fa = f(a);
    fb = f(b);
    
    % check roots
    if(abs(fa) <= eps)
        r = a;
        return;
    end;
    
    if(abs(fb) <= eps)
        r = b;
        return;
    end;
    
    % check bad input
    if(fb*fa>0)
        fprintf('Bad Input: f(b),f(a) same sign');
        return; 
    end;
    
    mu = 1;
    while(a~=b && abs(fb) > eps && fb ~= 0 && fa ~= fb)
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