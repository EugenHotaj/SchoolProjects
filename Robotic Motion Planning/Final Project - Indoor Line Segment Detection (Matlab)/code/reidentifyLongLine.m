function reidentifyLongLine( inputImages )
%reidentifyLines Given array of image names, find lines and reidentify

    %Variable used to store the longest line
    longest_line1 = -1;

    for imgNum = 1:length(inputImages(:,1))
        %read image
        curImg = imread(inputImages(imgNum,:));
        %convert to grayscale to work with the edge function
        curImg = rgb2gray(curImg);
        %perform canny alg on image
        cannyThresh = [0.05, 0.3];
        cannyImg = edge(curImg, 'canny', cannyThresh);
        %perform hough transform on result of canny
        [H,theta,rho] = hough(cannyImg);
        
        %from matlabs findlines tutorial
        P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
        x = theta(P(:,2));
        y = rho(P(:,1));
        
        lines = houghlines(cannyImg,theta,rho,P,'FillGap',25,'MinLength',50);
        
        figure, imshow(curImg), hold on
        max_len = 0;
        for k = 1:length(lines)
           xy = [lines(k).point1; lines(k).point2];
           plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

           % Plot beginnings and ends of lines
           plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
           plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

           % Determine the endpoints of the longest line segment
           len = norm(lines(k).point1 - lines(k).point2);
           if ( len > max_len)
              max_len = len;
              xy_long = xy;
           end
        end
        % highlight the longest line segment
        plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');

        if imgNum == 1
            %Save longest line, featureset, and image for use during second
            %image processing
            last_line = xy_long;
            last_img = curImg;
            last_points = detectHarrisFeatures(curImg);
            [last_features,last_valid_points] = extractFeatures(curImg,last_points);   
        else
            %Extract points using Harris & Stephens
            curPoints = detectHarrisFeatures(curImg);
            [features_cur,valid_points_cur] = extractFeatures(curImg,curPoints);
            
            indexPairs = matchFeatures(last_features,features_cur);
            
            matchedPoints1 = last_valid_points(indexPairs(:,1),:);
            matchedPoints2 = valid_points_cur(indexPairs(:,2),:);
            
            maxDifference = -1;
            %Combine the two images for display later
            C = imfuse(curImg,last_img,'blend','Scaling','joint');

            if (length(matchedPoints1)>0)
                %Loop through all matched features
                for i = 1:length(matchedPoints1)
                    %Compute distances from the longest lines to a matched feature
                    distance1 = sep(matchedPoints1(i).Location',last_line');
                    distance2 = sep(matchedPoints2(i).Location',xy_long');

                    difference = abs(distance1 - distance2);
                    %Set maxDifference to the largest discrepancy between
                    %any distance1 and distance2 values
                    if (difference>maxDifference)
                        maxDifference = difference;
                    end
                end
                
                figure, imshow(C), hold on
                %If there was a decently low maximum difference, highlight
                %the two longest lines to show they are the same
                if (maxDifference < 200)
                    plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue');
                    plot(last_line(:,1),last_line(:,2),'LineWidth',2,'Color','blue');
                end
            end
            
            %If there were no matched features, display the overlayed images
            %without highlighting lines to suggest no findings
            if (maxDifference == -1)
                figure, imshow(C), hold on
            end

            figure;
            showMatchedFeatures(last_img,curImg,matchedPoints1,matchedPoints2);
            
            %reset last_img params (for more than 2 images)
            last_line = xy_long;
            last_img = curImg;
            last_features = features_cur;
            last_valid_points = valid_points_cur;
            
        end %end if that checks which image is being processed
    end %end for that loops through input images
end

