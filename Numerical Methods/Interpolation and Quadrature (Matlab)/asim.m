function r  = asim(f,a,b,eps)
    % Adaptive Simpson Quadrature
    % Evaluates every interpolation point only once
    
    depth = 50;
    
    % Swap and negate if b<a
    sign = 1;
    if(b<a)
        sign = -1;
        [a,b] = deal(b,a);
    end
    
    % Fix endpts if needed
    if (~isfinite(f(a)))
        a = a + eps;
    end
    
    if(~isfinite(f(b)))
        b = b - eps;
    end
    
    ci = (b-a)/2;
    hi = b-a;
    
    fa = f(a);
    fb = f(b);
    fc = f(ci);
    
    si = (hi/6)*(fa+4*fc+fb); 
    r = rec(f,a,b,fa,fb,fc,si,eps,depth);

    function r = rec(f,a,b,fa,fb,fc,last,eps,depth)
        c = (a+b)/2;
        h = b-a;
        d = (a+c)/2;
        e = (c+b)/2;
        
        fd = f(d);
        fe = f(e);
        
        sl = (h/12)*(fa + 4*fd + fc);
        sr = (h/12)*(fc + 4*fe + fb);
        s = sl + sr;
        
        if(depth <= 0 || abs(s - last) <= 15*eps) % 15 from error analysis
            r = s + (s-last)/15;
        else
            r = rec(f,a,c,fa,fc,fd,sl,eps/2,depth-1) + ...
               rec(f,c,b,fc,fb,fe,sr,eps/2,depth-1);
        end
    end

    r = sign*r;
end