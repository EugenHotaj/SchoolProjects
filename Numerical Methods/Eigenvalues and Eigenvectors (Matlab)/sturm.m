function[L] = sturm(A)
    [a,b] = gersh(A);
    [m,~] = size(A);
    eps = 10^-6;
    
    i = 0;
    total = p(b);
    l = a;
    L = zeros(total,1);
    
    while i < total
        l = findLeast(l, b);
        i = i +1;
        L(i) = l;
    end
    
    % calculate smalles eigenvalues
    function[l0] = findLeast(a,b)
        b0 = b;
        pb = p(b);
        
        while(pb > 1)
            b0 = (a+b0)/2;
            pb = p(b0);
        end
        
        a0 = a;
        while(abs(a0-b0)>eps)
           mid = (a0 + b0)/2;
           pmid = p(mid);
           
           if(pmid == 1)
               b0 = mid;
           else
               a0 = mid;
           end
        end
        
        l0 = (a0+b0)/2;
    end

    % calculate sturum chain sign changes
    function[r] = p(x)
        r = 0;
        
        R = zeros(m+1,1);
        R(1) = 1;
        R(2) = A(1,1) - x;
        
        for j = 3:m+1
            R(j) = (A(j-1,j-1) - x)*R(j-1)-(A(j-2,j-1)^2)*R(j-2);
        end
        
        curr = sign(R(1));
        for j = 2:m+1
            if(curr * sign(R(j))<0)
                r = r +1;
                curr = sign(R(j));
            end
        end
        
        r = r - i;
    end
end