function J = drawlines(I,angles,displs)
    % angles in [0,pi]
    % displs in [-length(diag(I)),length(diag(I))]
    % I should be grayscale, in range [0,1]
    % J will be RGB, lines drawn in red
    J = repmat(0.5*I,[1 1 3]);
    for i = 1:length(angles)
        a = angles(i);
        d = displs(i);
        if a > pi/2 % displacement always negative
            v = [sin(a) -cos(a)];
            p = -d*v;
            x = p(1);
            y = p(2);
            c = round(x);
            r = round(size(I,1)-y);
            k = 0;
            while c > 1 && r > 1 && c <= size(I,2)-1 && r <= size(I,1)-1
                J(r-1:r+1,c-1:c+1,1) = 1;
                k = k+1;
                x = p(1)+k*cos(a);
                y = p(2)+k*sin(a);
                c = round(x);
                r = round(size(I,1)-y);
            end
            x = p(1);
            y = p(2);
            c = round(x);
            r = round(size(I,1)-y);
            k = 0;
            while c > 1 && r > 1 && c <= size(I,2)-1 && r <= size(I,1)-1
                J(r-1:r+1,c-1:c+1,1) = 1;
                k = k+1;
                x = p(1)-k*cos(a);
                y = p(2)-k*sin(a);
                c = round(x);
                r = round(size(I,1)-y);
            end
        else
            v = [-sin(a) cos(a)];
            p = d*v;
            x = p(1);
            y = p(2);
            c = round(x);
            r = round(size(I,1)-y);
            k = 0;
            while c <= size(I,2)-1 && r > 1
                if c > 1 && r <= size(I,1)-1
                    J(r-1:r+1,c-1:c+1,1) = 1;
                end
                k = k+1;
                x = p(1)+k*cos(a);
                y = p(2)+k*sin(a);
                c = round(x);
                r = round(size(I,1)-y);
            end
        end
    end
end