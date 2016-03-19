function F = featureset(B,E,r0) % box, environment, radius of robot
    F = []; % list of features (edges)
    for i = 1:length(E) % iterates through poligons
        P = E{i};
        P = [P P(:,1)];
        for j = 1:size(P,2)-1 % iterates through edges of poligon
            [s,p] = sep(B.center,P(:,j:j+1));
            if s <= r0+B.radius
                F = [F p];
            end
        end
    end
end