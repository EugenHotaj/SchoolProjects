function[r,it] = secant(f, a, b, eps)
    
    it = 0;
    fa = f(a);
    fb = f(b);

    % chek roots
    if(abs(fa) <= eps)
        r = a;
        return;
    end;
    
    if(abs(fb) <= eps)
        r = b;
        return;
    end;
    
    % check bad input
    if(a == b)
        fprintf('Bad Input: x0 == x1');
        return; 
    end;

    
    % check secant not horizontal
    if(fa == fb)
        fprintf('Bad Input: f(a) == f(b)');
        return;
    end;
    
    while(a~= b && abs(fb) > eps && fb ~= 0 && fa ~= fb)
       it = it+1;
       c = b - fb*((b-a)/(fb-fa)); % secant step
       
       a = b;
       b = c;
       fa = f(a);
       fb = f(b);
    end;
    
    r = b;
end