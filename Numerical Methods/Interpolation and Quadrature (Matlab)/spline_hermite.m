function [spl] = spline_hermite(t, y, dy)
%SPLINE_HERMITE cubic hermite spline
    
    n=length(t);
    
    S = zeros(n-1,4);
    
    for i=1:n-1,
        int=t(i+1)-t(i); 
        
        % get hermite coefficients
        a=(y(i+1)-y(i))/int;
        b=(a-dy(i))/int; 
        c=(dy(i+1)-a)/int; 
        d=(c-b)/int;
        
        S(i,:) = [a b c d];
    end
   
    % output data in needed format
    spl.S = S;
    spl.t = t;
    spl.y = y;
    spl.dy = dy;
end

