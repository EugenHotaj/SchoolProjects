function findlines(impath)

    threshold = .25;
    
    I = imread(impath);
    I = double(rgb2gray(I))/255;
    
    [M, D] = imgradient(I);
    
    % transform to hough space
    D(D < 0) = D(D < 0)+180; % 0 to 180
    D = D+90; % perpendicular, 90 to 270
    D(D > 180) = D(D > 180)-180; % perpendicular, 0 to 180
    D = ceil(D); %round since index must be integer
    D(D == 180) = 0; % perpendicular, 0 to 179
    
    %diagonal length
    dg = ceil(sqrt(size(I,1)^2+size(I,2)^2));
    
    %hough accumulator space
    %angles go from 0 to 179, displacement goes from 0 to 2*dg
    A = zeros(180,2*dg);
    
    % run through image and accumulate hough space if above threshold
    for i = 2:size(M,1)-1 % account for boundry
        for j = 2:size(M,2)-1 % account for boundry
            if M(i,j) > threshold
                x = j; % from left
                y = size(M,1)-i; % from bottom
                a = D(i,j); % angle of line
                
                % displacement of line
                d = round(dot([-sin(a/180*pi), cos(a/180*pi)], [x, y]));
                d = d+dg; % transform to hough space
                
                % increment accumulator
                A(a+1,d) = A(a+1,d) + M(i,j);
            end
        end
    end
    
    % Re-size image to find local maxima
    % making square to give both dimensions equal weight
    sa = 360;
    A = imresize(A, [sa sa]);
    
    % blurring image to make local maxima location more robust
    A = imfilter(A, fspecial('gaussian',12,3));
    
    % find local maxima
    m = max(max(A));
    BW = imregionalmax(A).*(A > .25*m);
    
    [rows, cols] = find(BW == 1);
    
    %recompute angles and displacements based on original
    angles = (rows-1)/sa*pi; % 0 to pi
    displs = (cols-sa/2)/(sa/2)*dg; %-dg to dg
    
    % draw image 
    imshow(drawlines(I,angles,displs));
end
