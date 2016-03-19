function [s,p] = sep(q,P)

% separation between point q and polygon P (actually, only a point or an edge)

if size(P,2) == 1 % P is a point
    s = norm(P-q);
    p = P;
elseif size(P,2) == 2 % P is a pair of points
    a = P(:,1);
    b = P(:,2);

    t = dot(q-a,b-a)/norm(b-a)^2;

    if t <= 0 % q is closest to a
        s = norm(a-q);
        p = a;
    elseif t >= 1 % q is closest to b
        s = norm(b-q);
        p = b;
    else
        p = (1-t)*a+t*b; % q is closest to some point in between a and b
        s = norm(p-q);
    end
end

end
