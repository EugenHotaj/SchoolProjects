function T = hh_tridiag(A)

[m, n] = size(A);
if m~=n || ~isequal(A,A')  %This just screens matricies that can't work.
   error('Matrix must be square symmetric only, see help.');
end

I = eye(n);  
Aold = A;  

for i=1:n-2
    v = zeros(n,1);
    v(i+1) = sqrt(.5*(1+abs(Aold(i+1,i))/(norm(A(i+1:end,i)))));
    v(i+2:n) = Aold(i+2:n,i)*sign(Aold(i+1,i))/(2*v(i+1)*norm(A(i+1:end,i)));
    
    P = I-2*v*v';
    Aold = P*Aold*P;
end
T = Aold;