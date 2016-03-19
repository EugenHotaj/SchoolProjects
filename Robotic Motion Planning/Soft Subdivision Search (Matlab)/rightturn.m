function T = rightturn(a,b,q)
    % tests if a->b->q is a right turn
    T = 0;
    if det([b-a q-a]) < 0
        T = 1;
    end
end