function[d,t] = sep(q, seg)
    
    % check dimensions of p
    [m,n] = size(q);
    if(m~=2 || n~=1)
        error('q must be a 2x1 vector represantation of a point');
    end;
    
    % check dimensions of seg
    [m,n] = size(seg);
    if(m~=2 || n~=2)
        error('seg must be a 2x2 matrix representation of a line segment');
    end;
    
    a = seg(:,1);
    b = seg(:,2);
    
    t = dot(q-a,b-a)/dot(b-a,b-a);
    
    % check bounds
    if(t>1) t = 1; end;
    if(t<0) t = 0; end;
    
    d = norm(((1-t)*a+t*b)-q);
end