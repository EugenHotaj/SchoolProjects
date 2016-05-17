function findlineshv(impath)
    
    % read image and normalize
    I = imread(impath);
    I = double(rgb2gray(I))/255; 
    
    % find vertical gradient and 'horizontal' (i.e rotated) gradient
    [V, ~] = imgradient(I);
    [H, ~] = imgradient(imrotate(I,90));
    
    % find peaks of image by summing over columns/'rows'
    Vsum = sum(V);
    Hsum = sum(H);
    
    % smooth peaks to remove double lines
    Vsum = smooth(Vsum);
    Hsum = smooth(Hsum);
    
    vm = max(Vsum);
    hm = max(Hsum);
   
    % find peak locations > than .5*max peak
    [~,Vpeaks] = findpeaks(Vsum,'MinPeakHeight', .5*vm);
    [~,Hpeaks] = findpeaks(Hsum,'MinPeakHeight', .5*hm);
    
    % draw straight red lines at peaks 
    I = repmat(I,[1 1 3]);
    
    for i=1:length(Hpeaks)
       curr = Hpeaks(i);
       I(curr-1:curr+1,:,1) = 1;
       I(curr-1:curr+1,:,2:3) = 0;
    end
    
    for i=1:length(Vpeaks)
       curr = Vpeaks(i);
       I(:,curr-1:curr+1,1) = 1;
       I(:,curr-1:curr+1,2:3) = 0;
    end
    
    imshow(I);
    
end