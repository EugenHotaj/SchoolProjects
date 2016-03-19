%
function T = inclusiontest(B,E)

% tests of box B is contained in some polygon of environment E

% ms is "minimum separation"
ms = Inf;	% initially "ms" is infinity

for i = 1:length(E) % iterates through polygons
    P = E{i};
    P = [P P(:,1)]; % extends P by adding the first vertex 
    for j = 1:size(P,2)-1 % iterates through edges of polygon
        [s,p] = sep(B.center,P(:,j:j+1));
        if s < ms	% s is smaller than current ms 
            ms = s;
            iP = i; % index of polygon
            if p == P(:,j)
                iE = j;		% index of first corner 
            elseif p == P(:,j+1)
                iE = j+1;	% or, index of next corner
            else
                iE = [j j+1];	% or, index of edge
            end
        end
    end
end

if length(iE) > 1 % closest environment point is edge
    P = E{iP};
    
    if iE(2) <= size(P,2)
        a = P(:,iE(1));
        b = P(:,iE(2));
    else
        a = P(:,iE(1));
        b = P(:,1);
    end
        
    if rightturn(a,b,B.center) == 1
        T = 0; % outside
    else
        T = 1; % inside
    end
        
else % closest environment point is corner
    P = E{iP};
    corner = P(:,iE);
    if iE == 1
        beforecorner = P(:,end);
        aftercorner = P(:,2);
    elseif iE == size(P,2)
        beforecorner = P(:,end-1);
        aftercorner = P(:,1);
    else
        beforecorner = P(:,iE-1);
        aftercorner = P(:,iE+1);
    end
    
    if rightturn(beforecorner,corner,aftercorner) == 1
        T = 1; % inside
    else
        T = 0; % outside
    end
end

end
