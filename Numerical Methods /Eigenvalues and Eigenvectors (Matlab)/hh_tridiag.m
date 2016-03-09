function T = hh_tridiag(A)

[m, n] = size(A);

% check square
if(m~=n) 
    error('Matrix must be square.');
end

% check symmetric
if(~issymmetric(A))
    error('Matrix must be symmetric.');
end

I = eye(n);  
Aold = A;  

for i=1:n-2
    v = zeros(n,1);
    
    v(i+1) = sqrt(.5*(1+abs(Aold(i+1,i))/(norm(A(i+1:end,i))))); 
    v(i+2:n) = Aold(i+2:n,i)*sign(Aold(i+1,i))/(2*v(i+1)*norm(A(i+1:end,i)));
    
    H = I-2*v*v';
    Aold = H*Aold*H;
end
T = Aold;