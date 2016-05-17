function [ yy ] = spline_nc_eval( pp, xx )
%SPLINE_NC_EVAL evaluates natural cubic spline
%	this function assumes that t(1) <= xx <= t(m)
%  if the above condition is broken, function breaks

	S = pp.S;
	t = pp.t;
	cp = 1;

	n = length(xx);

	yy = zeros(n,1);

	for i=1:n
		while(xx(i) > t(cp+1))
			cp = cp + 1;
 		end

		yy(i) =	  S(cp,1)*(xx(i)-t(cp))^3 ...
					+ S(cp,2)*(xx(i)-t(cp+1))^3 ...
					+ S(cp,3)*(xx(i)-t(cp)) ...
					+ S(cp,4)*(xx(i)-t(cp+1));
	end
end
