classdef Box < handle % supposed to be square
    properties
        x % counterclockwise from bottom left
        y % counterclockwise from bottom left
        center
        radius % of circle containing box
        sz % of edge (all edges have same size)
        label % 'free', 'stuck', 'mixed'
        parent % uf parent
        
        % adj lists
        % adj{1} = west
        % adj{2} = south
        % adj{3} = east
        % asj{4} = north
        adj
        
    end
    methods
        function obj = Box(x,y)
            obj.x = x;
            obj.y = y;
            obj.center = [(x(1)+x(2))/2; (y(1)+y(4))/2];
            obj.radius = norm([x(1); y(1)]-obj.center);
            obj.sz = x(2)-x(1);
            obj.label = 'mixed';
            obj.parent = [];
            for i = 1:4
                obj.adj{i} = {};
            end
        end
        
        function b = contains(obj,p)
            if(p(1) >= obj.x(1) && p(1) <= obj.x(2) ...
                    && p(2) >= obj.y(1) && p(2) <= obj.y(3))
                b = 1;
            else
                b =0;
            end
        end
        
        function BS = split(obj)
            x1 = obj.x(1);
            x2 = obj.x(2);
            y1 = obj.y(1);
            y2 = obj.y(4);

            xM = (x1+x2)/2;
            yM = (y1+y2)/2;
            
            BS{1} = Box([x1 xM xM x1],[y1 y1 yM yM]); %bl 
            BS{2} = Box([xM x2 x2 xM],[y1 y1 yM yM]); %br
            BS{3} = Box([xM x2 x2 xM],[yM yM y2 y2]); %tr
            BS{4} = Box([x1 xM xM x1],[yM yM y2 y2]); %tl
            
            % resolve adjecencies 
            % add siblings
            BS{1}.adj{4} = {BS{4}};
			BS{4}.adj{2} = {BS{1}};

			BS{1}.adj{3} = {BS{2}};
			BS{2}.adj{1} = {BS{1}};

			BS{2}.adj{4} = {BS{3}};
			BS{3}.adj{2} = {BS{2}};

			BS{3}.adj{1} = {BS{4}};
			BS{4}.adj{3} = {BS{3}};
            
            % add parent dependencies
            %BS{1} 
            [~,n] = size(obj.adj{1});            
	    	for i = 1:n
                seg = [obj.adj{1}{i}.x(2),obj.adj{1}{i}.x(3); obj.adj{1}{i}.y(2),obj.adj{1}{i}.y(3)];
                if(sep(BS{1}.center,seg)<BS{1}.radius)
                    if(isempty(BS{1}.adj{1}))
						BS{1}.adj{1} = {obj.adj{1}{i}};
					else
						BS{1}.adj{1} = {BS{1}.adj{1}{:} obj.adj{1}{i}};
					end
                    obj.adj{1}{i}.adj{3} = {obj.adj{1}{i}.adj{3}{:} BS{1}};
                end
            end
            [~,n] = size(obj.adj{2});
            for i = 1:n
                seg = [obj.adj{2}{i}.x(3),obj.adj{2}{i}.x(4); obj.adj{2}{i}.y(3),obj.adj{2}{i}.y(4)];
                if(sep(BS{1}.center,seg)<BS{1}.radius)
                    if(isempty(BS{1}.adj{2}))
						BS{1}.adj{2} = {obj.adj{2}{i}};
					else
						BS{1}.adj{1} = {BS{1}.adj{2}{:} obj.adj{2}{i}};
					end
                    obj.adj{2}{i}.adj{4} = {obj.adj{2}{i}.adj{4}{:} BS{1}}; 
                end
            end
            
            %BS(2)
            [~,n] = size(obj.adj{3});
            for i = 1:n
                seg = [obj.adj{3}{i}.x(4),obj.adj{3}{i}.x(1); obj.adj{3}{i}.y(4),obj.adj{3}{i}.y(1)];
                if(sep(BS{2}.center,seg)<BS{2}.radius)
                    if(isempty(BS{2}.adj{3}))
						BS{2}.adj{3} = {obj.adj{3}{i}};
					else
						BS{2}.adj{3} = {BS{2}.adj{3}{:} obj.adj{3}{i}};
					end
                    obj.adj{3}{i}.adj{1} = {obj.adj{3}{i}.adj{1}{:} BS{2}}; 
                end
            end
            [~,n] = size(obj.adj{2});
            for i = 1:n
                seg = [obj.adj{2}{i}.x(3),obj.adj{2}{i}.x(4); obj.adj{2}{i}.y(3),obj.adj{2}{i}.y(4)];
                if(sep(BS{2}.center,seg)<BS{2}.radius)
                    if(isempty(BS{2}.adj{2}))
						BS{2}.adj{2} = {obj.adj{2}{i}};
					else
						BS{2}.adj{2} = {BS{2}.adj{2}{:} obj.adj{2}{i}};
					end
                    obj.adj{2}{i}.adj{4} = {obj.adj{2}{i}.adj{4}{:} BS{2}}; 
                end
            end
            
            %BS(3)
            [~,n] = size(obj.adj{3});
            for i = 1:n
                seg = [obj.adj{3}{i}.x(4),obj.adj{3}{i}.x(1); obj.adj{3}{i}.y(4),obj.adj{3}{i}.y(1)];
				if(sep(BS{3}.center,seg)<BS{3}.radius)
                   if(isempty(BS{3}.adj{3}))
						BS{3}.adj{3} = {obj.adj{3}{i}};
					else
						BS{3}.adj{3} = {BS{3}.adj{3}{:} obj.adj{3}{i}};
					end
                    obj.adj{3}{i}.adj{1} = {obj.adj{3}{i}.adj{1}{:} BS{3}}; 
		end
            end
            [~,n] = size(obj.adj{4});
            for i = 1:n
                seg = [obj.adj{4}{i}.x(1),obj.adj{4}{i}.x(2); obj.adj{4}{i}.y(1),obj.adj{4}{i}.y(2)];
                if(sep(BS{3}.center,seg)<BS{3}.radius)
                   if(isempty(BS{3}.adj{4}))
						BS{3}.adj{4} = {obj.adj{4}{i}};
					else
						BS{3}.adj{4} = {BS{3}.adj{4}{:} obj.adj{4}{i}};
					end
                    obj.adj{4}{i}.adj{2} = {obj.adj{4}{i}.adj{2}{:} BS{3}}; 
                end
            end
            
            %BS(4)
            [~,n] = size(obj.adj{1});
            for i = 1:n
                seg = [obj.adj{1}{i}.x(2),obj.adj{1}{i}.x(3); obj.adj{1}{i}.y(2),obj.adj{1}{i}.y(3)];
                if(sep(BS{4}.center,seg)<BS{4}.radius)
                    if(isempty(BS{4}.adj{1}))
						BS{4}.adj{1} = {obj.adj{1}{i}};
					else
						BS{4}.adj{1} = {BS{4}.adj{1}{:} obj.adj{1}{i}};
					end
                    obj.adj{1}{i}.adj{3} = {obj.adj{1}{i}.adj{3}{:} BS{4}}; 
                end
            end
            [~,n] = size(obj.adj{4});
            for i = 1:n
                seg = [obj.adj{4}{i}.x(1),obj.adj{4}{i}.x(2); obj.adj{4}{i}.y(1),obj.adj{4}{i}.y(2)];
                if(sep(BS{4}.center,seg)<BS{4}.radius)
                    if(isempty(BS{4}.adj{4}))
						BS{4}.adj{4} = {obj.adj{4}{i}};
					else
						BS{4}.adj{4} = {BS{4}.adj{4}{:} obj.adj{4}{i}};
					end
                    obj.adj{4}{i}.adj{2} = {obj.adj{4}{i}.adj{2}{:} BS{4}}; 
                end
            end
        end
    end
end
