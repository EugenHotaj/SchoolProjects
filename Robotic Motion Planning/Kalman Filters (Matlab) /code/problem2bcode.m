%create 300px x 400px black image to draw the lines on
I = zeros(300,400);
%line of angle 135 degrees, above the bottom left of the image
%whose distance to (0,0) is 200px
drawlines(I, 2.37, -200);
figure;
imshow(ans);
%line of angle 45 degrees, crossing the bottom of the image
%whose distance to (0,0) is 100px
drawlines(I, .785, -100);
figure;
imshow(ans);
%line of angle 30 degrees, extending above the bottom left of the image
%whose distance to (0,0) is 50px
drawlines(I, .524, 50);
figure;
imshow(ans);