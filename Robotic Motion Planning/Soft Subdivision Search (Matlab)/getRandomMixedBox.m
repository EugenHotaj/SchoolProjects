function [B,QOut] = getRandomMixedBox(QIn)
   
    B = [];
    boxesLeft = QIn;
    QOut = QIn;
    
    % pick random box until we find a mixed one
    i = randi(length(QIn),1,1);
    BI = QIn{i};
    while ~isempty(boxesLeft) && ~strcmp(BI.label,'mixed')
        %remove this non-mixed box from our remaining options
        boxesLeft = {boxesLeft{1:i-1} boxesLeft{i+1:end}};
        %search again in remaining boxes
        if (~isempty(boxesLeft))
            i = randi(length(boxesLeft),1,1);
            BI = QIn{i};
        end
    end
    
    %if boxesLeft is not empty, we found a mixed box
    if (~isempty(boxesLeft))
        %remove box from queue and return
        B = BI;
        QOut = {QOut{1:i-1} QOut{i+1:end}};
    end
end