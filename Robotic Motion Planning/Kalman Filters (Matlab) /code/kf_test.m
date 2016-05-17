for i=1:3
    
    % compute newppp
    newppp = kf_filter(ppp,i);
    
    % draw the 6 figures (self explanitory code)
    figure('OuterPosition', [0 0 1000 500]);
    title('Ideal Distance (wrt. Speed) vs Time');
    ylabel('Ideal Distance (wrt. Speed)');
    xlabel('Time');
    hold on;
    plot(1:newppp.N,newppp.XI(1,:),'b--o',1:newppp.N,newppp.XI(2,:),'r--o');
    hold off;
    
    figure('OuterPosition', [0 0 1000 500]);
    title('Idea Distance-Speed Plot');
    ylabel('Speed');
    xlabel('Distance');
    hold on;
    plot(newppp.XI(1,:),newppp.XI(2,:),'g--o');
    hold off;
    
    figure('OuterPosition', [0 0 1000 500]);
    title('Observed Distance (wrt Speed) vs Time (blue) vs Actaual (red)');
    ylabel('Observed Distance (wrt Speed)');
    xlabel('Time');
    hold on
    plot(1:newppp.N,newppp.XX(1,:),'r--o',1:newppp.N,newppp.XX(2,:),'r--o');
    plot(1:newppp.N,newppp.ZZ(1,:),'b--o',1:newppp.N,newppp.ZZ(2,:),'b--o');
    hold off
    
    figure('OuterPosition', [0 0 1000 500]);
    title('Observed Distance-Speed (blue) vs Actual (red)');
    ylabel('Noisy Speed');
    xlabel('Noisy Distance');
    hold on
    plot(newppp.XX(1,:),newppp.XX(2,:),'r--o');
    plot(newppp.ZZ(1,:),newppp.ZZ(2,:),'b--p');
    hold off
    
    figure('OuterPosition', [0 0 1000 500]);
    title('KF Distance (wrt Speed) vs Time (green) vs Actual (blue)');
    ylabel('KF Distance (wrt Speed)');
    xlabel('Time');
    hold on
    plot(1:newppp.N,newppp.XH(1,:),'g--o',1:newppp.N,newppp.XH(2,:),'g--o');
    plot(1:newppp.N,newppp.XX(1,:),'b--o',1:newppp.N,newppp.XX(2,:),'b--o');
    hold off
    
    figure('OuterPosition', [0 0 1000 500]);
    title('KF Distance-Speed (green) vs Actual (blue)');
    ylabel('KF Speed');
    xlabel('KF Distance');
    hold on
    plot(newppp.XX(1,:),newppp.XX(2,:),'b--o');
    plot(newppp.XH(1,:),newppp.XH(2,:),'g--p');
    hold off
end