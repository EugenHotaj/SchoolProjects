function [B,QOut] = getmixedbox(QIn)
    % pick first box whose label is 'mixed', if there's any,
    % and remove it from the queue Q
    B = [];
    QOut = QIn;
    for i = 1:length(QIn)
        BI = QIn{i};
        if strcmp(BI.label,'mixed')
            B = BI;
            QOut = {QOut{1:i-1} QOut{i+1:end}};
            break;
        end
    end
end