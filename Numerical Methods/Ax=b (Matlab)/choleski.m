function [L,U] = choleski(A)
    [n, m] = size(A);

    % check size
    if (n ~= m) 
        error('Matrix must be square.');
    end
    
    % check symmetric
    if(~issymmetric(A))
        error('Matrix must be symmetric.');
    end
    
    function C = pack(M)
        c = find(M(1,1:n)~=0);
        C = zeros(n,c(end));

        p = c(end)-1;
        for i=1:n
            if i<=n-p
                for j=i:p+i
                    C(i,j-i+1)=M(i,j);
                end
            else 
                for j=i:n
                    C(i,j-i+1)=M(i,j);
                end
            end
        end
    end

    function C = unpack(M)
        [x,y] = size(M);
        C = zeros(n);
        for i=1:x
            for j=1:y
                ind = i+j-1;
                if ind <= x
                    C(i,ind) = M(i,j);
                end
            end
        end
    end

    function C = chol(M)
        [x,p] = size(M);  
        p = p - 1;
        C = M;
        for k = 1:x
            last = min(k+p,x) - k + 1;
            for j = 2:last
                i = k + j - 1;
                C(i,1:last-j+1) = C(i,1:last-j+1) - ((C(k,j))/C(k,1))*C(k,j:last); 
            end
            
            % check pos def
            if(C(k,1)<0)
                error('Matrix must be positive definite.');
            end
            
            C(k,:) = C(k,:)/sqrt(C(k,1));
        end
        C(end-(p-1):end,end) = 0;
    end

U = unpack(chol(pack(A)));
L = U';
end