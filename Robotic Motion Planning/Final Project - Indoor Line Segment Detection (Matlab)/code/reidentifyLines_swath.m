function[map] =  reidentifyLines_swath( inputImages )
% reidentifyLines Given array of image names, find lines and reidentify
% this is the swath version of reidentify lines
    
    map = {};

    for imgNum = 1:length(inputImages(:,1))
        
        % read image and convert to grayscale
        curImg = imread(inputImages(imgNum,:));
        curImg = rgb2gray(curImg);

		% find canny point proposals
        cannyThresh = [0.05, 0.3];
        cannyImg = edge(curImg, 'canny', cannyThresh);

        % find lines through hough transform on canny proposals
        [H,theta,rho] = hough(cannyImg);
        P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
        lines = houghlines(cannyImg,theta,rho,P,'FillGap',200,'MinLength',250);
        
		% plotting and current image map construction
        figure, imshow(curImg), hold on
        
		% append to map for current image
        map = swath_map(lines,map,curImg);
    end
    
    function[map] = swath_map(lines, map, img)
        newmap = {}; % current image map
        len = 0; % current image map length
        
        for i = 1:length(lines)
            % points array for easier plotting
            xy = [lines(i).point1; lines(i).point2];
            
            curr = lines(i);
            flag = 1;          % flag to check if line in global map
            match = -1;        % index of match
            color = rand(1,3); % random color to assign a new line 
            
            % build line features
            p1 = curr.point1;
            p2 = curr.point2;
                
            t = curr.theta;
            r = curr.rho;
            slope = (p2(2) - p1(2))/(p2(1) - p1(1));
            p1_swath = img(p1(1)-1:1:p1(1)+1,p1(2)-1:1:p1(2)+1);
            p2_swath = img(p2(1)-1:1:p2(1)+1,p2(2)-1:1:p2(2)+1);
            
            % creat feature struct
            curr_s = struct('s',slope, 'p1_swath',p1_swath, ...
                            'p2_swath',p2_swath,'color',color, ...
                            'rho',r, 'theta', t);
            
            % (naive) search for match    
            for j=1:length(map)
                if test_same(map{j}, curr_s)
                    flag = 0;
                 	match = j;
                 	break;
                end
            end
            
            % plotting 
           	if flag
                % if line not in global map, plot, add to current image map
                len = len + 1;
                newmap{len} = curr_s;
                match = len;
                plot(xy(:,1),xy(:,2),'LineWidth',3,'Color',newmap{match}.color);
            else
                % if line in global map, plot with corresponding color
                plot(xy(:,1),xy(:,2),'LineWidth',3,'Color',map{match}.color);
            end
            
            % plot endpoints of line
          	plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
            plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    	  end
        
		% append current image map to global map
        lenmap = length(map);
        for i = 1:length(newmap)
            lenmap = lenmap + 1;
            map{lenmap} = newmap{i};
        end
    end
    
    % similarity function (thresholds based on best attained results)
    function[bool] =  test_same(l1,l2)
	 	bool = 0;
        if abs(l1.s-l2.s) < 3 && ...
           abs(abs(l1.rho)-abs(l2.rho))<50 && ...
           abs(abs(l1.theta)-abs(l2.theta))<10 && ...
           sum(sum(abs(l1.p1_swath - l2.p1_swath))) < 9 * 20 && ...
           sum(sum(abs(l1.p2_swath - l2.p2_swath))) < 9 * 20 
            bool = 1;
        end
    end
end

