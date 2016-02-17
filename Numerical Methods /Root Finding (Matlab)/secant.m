function[r,it] = secant(f, a, b, eps)
    
    % check bad input
    if(a == b)
        fprintf('Bad Input: x0 == x1');
        return; 
    end;
    
    it = 0;
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
    
    % check secant not horizontal
    if(fa == fb)
        fprintf('Bad Input: f(a) == f(b)');
        return;
    end;
    
    while(abs(fb) > eps && fb ~= 0 && fa ~= fb)
       it = it+1;
       c = b - fb*((b-a)/(fb-fa)); % secant step
       
       a = b;
       b = c;
       fa = f(a);
       fb = f(b);
    end;
    
    r = b;
end