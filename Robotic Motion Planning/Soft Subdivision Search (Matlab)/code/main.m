% file name: main.m
%
% This should be the main program to run your program!!
%

%load "test1", "test2", "test3", or "test4"
load test1
r0 = test.radius;
minradius = 0.1;
%strategy = 'bfs' for breadth-first-search or 'ran' for random
strategy = 'bfs';

% containing box
B = Box(test.box(1,:),test.box(2,:));

Q = {B};
E = test.env;

s=B;
f=B;
if(strcmp(strategy, 'bfs'))
    [B,Q] = getmixedbox(Q);
elseif(strcmp(strategy, 'ran'))
    [B,Q] = getRandomMixedBox(Q);
end
while ~isempty(B) % there is a 'mixed' box
    BS = B.split; % all boxes are initilized as 'mixed'
    for i = 1:4
        if(BS{i}.contains(test.start))
            s = BS{i};
        end
        
        if(BS{i}.contains(test.goal))
            f = BS{i};
        end
        
        if BS{i}.radius < minradius
            BS{i}.label = 'small';
        else
            F = featureset(BS{i},E,r0);
            if isempty(F)
                BS{i}.label = 'stuckorfree';
            end
        end
    end
    Q = {Q{:} BS{:}}; % add 4 new boxes to the queue

    if(strcmp(strategy, 'bfs'))
        [B,Q] = getmixedbox(Q);
    elseif(strcmp(strategy, 'ran'))
        [B,Q] = getRandomMixedBox(Q);
    end
end

for i = 1:length(Q)
    if strcmp(Q{i}.label,'stuckorfree')
        if (inclusiontest(Q{i},E))
            Q{i}.label = 'stuck';
        else
            Q{i}.label = 'free';
            for j=1:4
               currList = Q{i}.adj{j};
               [~,n] = size(currList);
               for k=1:n
                   curr = currList{k};
                   if(strcmp(curr.label,'free'))
                        ufUnion(Q{i},curr);
                   end
               end
            end
        end
    end
end

if(eq(ufFind(s),ufFind(f)))
    disp('PATH EXISTS');
else
    disp('NO PATH');
end

for i = 1:length(Q)
    B = Q{i};
    if strcmp(B.label,'stuck')
        patch(B.x,B.y,'red')
    elseif strcmp(B.label,'free')
        patch(B.x,B.y,'green')
    elseif strcmp(B.label,'small')
         patch(B.x,B.y,[0.7 0.7 0.7])
    elseif strcmp(B.label,'mixed')
        patch(B.x,B.y,'yellow')
    end
end

patch([test.start(1)-.1,test.start(1)+.1,test.start(1)+.1,test.start(1)-.1], ...
    [test.start(2)-.1,test.start(2)-.1, test.start(2)+.1,test.start(2)+.1],...
    'black');

patch([test.goal(1)-.1,test.goal(1)+.1,test.goal(1)+.1,test.goal(1)-.1], ...
    [test.goal(2)-.1,test.goal(2)-.1, test.goal(2)+.1,test.goal(2)+.1],...
    'black');
%axis equal, axis tight, axis off
