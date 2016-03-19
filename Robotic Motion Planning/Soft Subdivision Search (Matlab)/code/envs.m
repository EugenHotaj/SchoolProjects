% file: envs.m
%
% This file sets up the "test" data structures
%	which corresponds to a complete set of inputs
%	for the planning algorithm.
%
% The "test" object is saved in a file called "test1.mat"
test.radius = 1.5;
test.start = [-2; 0];
test.goal = [5; -3];
test.eps = 0.2; % epsilon
test.strategy = 'ran';		% random strategy
test.box = [-4 6 6 -4; -4 -4 6 6];
% test.env = {[-3 2 2 -3; 2.5 2.5 5 5],...
%             [3 5 3; 2.5 2.5 5],...
%             [-2 2; -2 -2]};
% test.env = {[-3 2 2 -3; 2.5 2.5 5 5],...
%             [3 5 3; 2.5 2.5 5]};
test.env = {[-3 2 2 -3; 2.5 2.5 5 5],...
            [3 5 3; 2.5 2.5 5],...
            [-2 2 2 -2; -2.0001 -2.0001 -1.9999 -1.9999]};

% Displays the background box:
patch(test.box(1,:),test.box(2,:),'g')

% axis tight, axis equal, axis off

for i = 1:length(test.env)
    p = test.env{i};
    patch(p(1,:),p(2,:),'g')
end

% Saves the "test" object in a file called "test1.mat":
save test1 test
