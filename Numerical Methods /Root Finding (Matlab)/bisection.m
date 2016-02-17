function[r,it] = bisection(f,a,b,eps)
    
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
    
    % check bad input
    if(fa*fb>0)
        fprintf('Bad Input: f(a),f(b) same sign');
        return;
    end;
    
    while(abs(a-b)>eps),
        it = it + 1;
        mid = (a+b)/2;
        fmid = f(mid);
        
        if(fmid==0)
            r = mid;
            return;
        end;
        
        if(fmid*fa>0)
            a = mid;
            fa = f(a);
        else
            b = mid;
            fb = f(b);
        end;
    end;
    
    r = (a+b)/2;
end