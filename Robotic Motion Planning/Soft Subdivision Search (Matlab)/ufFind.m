function [p] = ufFind(x)
    p = x.parent;
    
    if(isempty(p) || eq(p,x))
       p = x; 
       return;
    end
    
    p = ufFind(p);
end

