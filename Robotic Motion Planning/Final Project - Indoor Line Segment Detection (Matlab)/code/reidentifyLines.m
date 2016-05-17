function reidentifyLines(inputImages, fill, minLine, matchThresh)
%reidentifyLines Given array of image names, find lines and reidentify
    colors = {'b','g','y','m','c','b','g','y','m','c','b','g','y','m','c','r'};
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
        P = houghpeaks(H,5,'threshold',ceil(0.4*max(H(:))));
        lines = houghlines(cannyImg,theta,rho,P,'FillGap',fill,'MinLength',minLine);
        
        %first imgage is just setup - store first image and first image lines
        if imgNum == 1
            last_img = curImg;
            %find image features from Harris-Stephens algorithm
            last_points = detectHarrisFeatures(curImg);
            [last_features,last_valid_points] = extractFeatures(curImg,last_points);
            last_lines = lines;
        %subsequent images get lines of current image and compare to last
        else
            curPoints = detectHarrisFeatures(curImg);
            [features_cur,valid_points_cur] = extractFeatures(curImg,curPoints);
            %match the feature points of the two images
            indexPairs = matchFeatures(last_features,features_cur);
            matchedPoints1 = last_valid_points(indexPairs(:,1),:);
            matchedPoints2 = valid_points_cur(indexPairs(:,2),:);
            
            %show the matched features on a figure
            figure
            showMatchedFeatures(last_img,curImg,matchedPoints1,matchedPoints2);
            
            last_lines_dist = [1:length(last_lines);1:length(last_lines)];
            
            %for each line in last lines, find total distance from all matched points
            for lastCurLineNum = 1 : length(last_lines)
                lineStart = last_lines(lastCurLineNum).point1;
                lineEnd = last_lines(lastCurLineNum).point2;
                P = [lineStart; lineEnd];
                curDist = 0;
                %for each feature, accumulate total distance from line to
                %all features
                for pointNum = 1 : length(matchedPoints1)
                    [curSep, throwaway] = sep(matchedPoints1(pointNum).Location',P');
                    curDist = curDist + curSep;
                end
                %store distance to current line in last_lines_dist
                last_lines_dist(2,lastCurLineNum) = curDist;
            end
            
            figure, imshow(last_img), hold on
            for k = 1:length(last_lines)
               xy = [last_lines(k).point1; last_lines(k).point2];
               plot(xy(:,1),xy(:,2),'LineWidth',3,'Color',colors{k});
            end
            
            cur_lines_dist = [1:length(lines);1:length(lines)];
            %repeat above process for the current lines and features
            for curLineNum = 1 : length(lines)
                lineStart = lines(curLineNum).point1;
                lineEnd = lines(curLineNum).point2;
                P = [lineStart; lineEnd];
                curDist = 0;
                for pointNum = 1 : length(matchedPoints2)
                    [curSep, throwaway] = sep(matchedPoints2(pointNum).Location',P');
                    curDist = curDist + curSep;
                end
                cur_lines_dist(2,curLineNum) = curDist;
            end
            
            matched_index = [1:length(cur_lines_dist)];
            
            %compare cur_lines_dist to last_lines_dist
            for lineIndex = 1 : length(cur_lines_dist)
                best = 100;
                bestI = 16;
                for matchIndex = 1 : length(last_lines_dist)
                    cur = abs(1 - (cur_lines_dist(2,lineIndex) / last_lines_dist(2,matchIndex)));
                    if cur < best && cur < (1 - matchThresh)
                        best = cur; 
                        bestI = matchIndex;
                    end
                end
                matched_index(1,lineIndex) = bestI;
            end
            
            figure, imshow(curImg), hold on
            for k = 1:length(lines)
               xy = [lines(k).point1; lines(k).point2];
               plot(xy(:,1),xy(:,2),'LineWidth',3,'Color',colors{matched_index(1,k)});
            end
            
            %set cur image to last image - will be compared to the next img
            last_img = curImg;
            last_features = features_cur;
            last_valid_points = valid_points_cur;
            last_lines = lines;
        end
    end
end