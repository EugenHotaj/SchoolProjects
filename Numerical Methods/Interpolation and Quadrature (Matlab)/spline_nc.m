function [spl] = spline_nc(t,y)
% SPLINE_NC natural cubic spline

	n = length(t);

	% precompute h,b for convenience
	h = t(2:n)-t(1:n-1);
	b = (y(2:n)-y(1:n-1))./h;

	v = zeros(n,1);
	u = zeros(n,1);
	z = zeros(n,1);
	
	% precompute u,v for implicit tridiagonal solver
	u(2) = 2*(h(1)+h(2));
	v(2) = 6*(b(2)-b(1));

	for i=3:n-1
		u(i) = 2*(h(i)+h(i-1))-h(i-1)^2/u(i-1);
		v(i) = 6*(b(i)-b(i-1))-h(i-1)*v(i-1)/u(i-1);
	end

	% implicit tridiagonal solver (for above precomps)
	for i=n-1:-1:2
		z(i) = (v(i)-h(i)*z(i+1))/u(i);
	end

	% find spline pieces
	S = zeros(n-1,4);

	for i=1:n-1
		S(i,1) = z(i+1)/(6*h(i));
		S(i,2) = -z(i)/(6*h(i));
		S(i,3) = y(i+1)/h(i) - z(i+1)*h(i)/6;
		S(i,4) = -(y(i)/h(i) - z(i)*h(i)/6);
	end

	% output data in needed format
	spl.t = t;
	spl.z = z;
	spl.S = S;
end
