function ufUnion(x,y)
    px = ufFind(x);
    py = ufFind(y);
    
    if(ne(x,y))
        py.parent = px;
    end
end

