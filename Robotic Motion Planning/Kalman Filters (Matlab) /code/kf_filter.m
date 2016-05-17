function newppp = kf_filter(ppp,i)
    % some more set up
    ppp(i).XI(:,1) = [ppp(i).s0; ppp(i).v0]; % ideal
    ppp(i).XX(:,1) = ppp(i).XI(:,1) + ppp(i).PN(:,1); % actual
    ppp(i).ZZ(:,1) = ppp(i).XX(:,1) + ppp(i).ON(:,1); % observed
    
    for k=2:ppp(i).N
        
        % compute ideal
        ppp(i).XI(:,k) = ppp(i).A * ppp(i).XI(:,k-1);
        
        % compute model (actual, observed)
        ppp(i).XX(:,k) = ppp(i).A * ppp(i).XX(:,k-1) + ppp(i).PN(:,k);
        ppp(i).ZZ(:,k) = ppp(i).H * ppp(i).XX(:,k) + ppp(i).ON(:,k);
        
        % compute KF
        % predict
        ppp(i).XH(:,k) = ppp(i).A * ppp(i).XH(:,k-1);
        ppp(i).PH{k} = ppp(i).A*ppp(i).PH{k-1}*ppp(i).A' + ppp(i).Q;
        
        % update
        G = ppp(i).PH{k}*ppp(i).H'*(ppp(i).H*ppp(i).PH{k}*ppp(i).H' + ppp(i).R)^(-1);
        ppp(i).XH(:,k) = ppp(i).XH(:,k) + G*(ppp(i).ZZ(:,k) - ppp(i).H*ppp(i).XH(:,k));
        ppp(i).PH{k} = (eye(ppp(i).m,ppp(i).n) - G*ppp(i).H)*ppp(i).PH{k};
    end
    
    newppp = ppp(i);
end