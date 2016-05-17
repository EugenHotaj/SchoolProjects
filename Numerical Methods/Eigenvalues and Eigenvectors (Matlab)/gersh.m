function[a,b] = gersh(A)
    a = realmax;
    b = realmin;
    
    [m, ~] = size(A);
    B = abs(A);
    
    for i = 1:m
       
        if(i==1)
            currMax = A(1,1) + B(i,2);
            currMin = A(1,1) - B(i,2);
        elseif(i==m)
            currMax = A(i,i) + B(i,i-1);
            currMin = A(i,i) - B(i,i-1);
        else
            currMax = A(i,i) + B(i,i-1) + B(i,i+1);
            currMin = A(i,i) - B(i,i-1) - B(i,i+1);
        end
        
        if(currMax > b)
            b = currMax;
        end
        
        if(currMin < a)
            a = currMin;
        end
    end
end