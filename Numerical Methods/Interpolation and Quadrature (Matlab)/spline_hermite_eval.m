function [yy] = spline_hermite_eval(pp,xx)
%SPLINE_HERMITE_EVAL evaluates hermite spline
%Assumes that t(0) <= xx(i) <= t(m)
%If this condition is not met, function might break
    
    t  = pp.t;
    S  = pp.S;
    y  = pp.y;
    dy = pp.dy;
    cp = 1;
    
    n = length(xx);
    
    yy = zeros(n,1);
    
    for i=1:n
        while(xx(i) > t(cp+1))
            cp = cp+1;
        end
        
        % fast solver to reduce recomputations 
        yy(i)=y(cp)+(xx(i)-t(cp+1)).*(dy(cp)+(xx(i)-t(cp)).*(S(2)+(xx(i)-t(cp+1)).*S(4)));  
    end

end

