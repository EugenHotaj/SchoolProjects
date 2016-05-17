function [d] = test(n)

    f = @(x) 1./(1+25*x.^2);
    fp = @(x) -(50*x)./((25*x.^2+1).^2);
    c = @(x) cos(x*pi/n);
    
    xx = -1:.01:1;
    ryy = f(xx)';
    
    et = -1:2/n:1;
    ey = f(et);
    edy = fp(et);
    es = spline_hermite(et,ey,edy);
    eyy = spline_hermite_eval(es,xx);
    eerr = sum(abs(ryy-eyy));
    
    ct = -1*c(0:1:n);
    cy = f(ct);
    cdy = fp(ct);
    cs = spline_hermite(ct,cy,cdy);
    cyy = spline_hermite_eval(cs,xx);
    cerr = sum(abs(ryy-cyy));
    
    plot(xx,ryy,'g--',xx,eyy,'r',xx,cyy,'b');
    
    d = abs(eerr-cerr);
end
