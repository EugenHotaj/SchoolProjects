import pygame;
import random;
import sys;
import pickle;
import copy;
import numpy as np;
from pygame.locals import *;

### define game logic methods ####

def collide(x1, x2, y1, y2, w1, w2, h1, h2):
	if x1+w1>x2 and x1<x2+w2 and y1+h1>y2 and y1<y2+h2:
		return True;
	else:
		return False;

def rand_apple_pos():
	empty = np.where(grid==0);
	index = int(random.random()*len(empty[0]));
	pos = (empty[0][index],empty[1][index]);
	grid[pos[0]][pos[1]] = 2;
	return (pos[0]*obj_size, pos[1]*obj_size);

def left_turn(dirs):
	return (dirs+1)%4;

def right_turn(dirs):
	return (dirs-1)%4;

def forward(dirs):
	return dirs; #identity function to make some logic easier 

def move(xs, ys, dirs, flag):
	i = len(xs)-1;
	
	# change the last position to in grid empty
	if(flag and xs[i]/obj_size < grid_size and ys[i]/obj_size < grid_size):
		grid[xs[i]/obj_size][ys[i]/obj_size] = 0;
	
	while i >= 1:
		xs[i] = xs[i-1];
		ys[i] = ys[i-1];
		i -= 1

	# move head
	if dirs==0:
		ys[0] += obj_size;
	elif dirs==1:
		xs[0] += obj_size;
	elif dirs==2:
		ys[0] -= obj_size;
	elif dirs==3:
		xs[0] -= obj_size;

	# change head position to "snake" in grid
	if(flag and xs[i]/obj_size < grid_size and xs[i]/obj_size > -1 and ys[i]/obj_size < grid_size and ys[i]/obj_size > -1):
		grid[xs[i]/obj_size][ys[i]/obj_size] = 1;

def check_boundries(xs, ys):
	if xs[0] < 0 or xs[0] > (grid_size-1)*obj_size or ys[0] < 0 or ys[0] > (grid_size-1)*obj_size: 
		return True;
	return False;

def check_self(xs,ys):
	i = len(xs)-1
	while i >= 2:
		if collide(xs[0], xs[i], ys[0], ys[i], obj_size, obj_size, obj_size, obj_size):
			return True;
		i-= 1
	return False;

def check_apple(xs,ys):
	return collide(xs[0], applepos[0], ys[0], applepos[1], obj_size, obj_size, obj_size, obj_size);

### define init and main game loop ###
def init_game():
	global usr_FPS;
	curr_it = 0;
	usr_FPS = FPS;


	if TRAIN:
		global Q, Q_eps, Q_alpha, Q_gamma, Q_count, Q_runs;
		
		train_file = open("train","rb+");

		dump_limit = 200;
		dump_time = 0;
		curr_it = 0;

		obj = pickle.load(train_file);
		
		curr_it = obj["curr_it"];
		Q_eps = obj["eps"];
		Q_alpha = obj["alpha"];
		Q_gamma = obj["gamma"];
		Q_count = obj["count"];
		Q_runs = obj["runs"];
		Q_rand_states = obj["rand_states"]
		#Q = copy.deepcopy(obj[curr_it]);
		Q = obj["Q"];

		print("loaded training at " + str(curr_it));
	
	avg_score = 0;
	for i in range(curr_it,100000):
		curr_it += 1;

		if TRAIN:
			dump_time += 1;

			if(dump_time >= dump_limit):
				dump_time = 0;

				Q_runs = np.append(Q_runs, avg_score/dump_limit);
				
				print("Last avg 200 games: " + str(avg_score/dump_limit));

				avg_score = 0;
				
				for key in Q_rand_states:
					if key in Q:
						Q_rand_states[key] = np.append(Q_rand_states[key],max(Q[key]));

				obj["rand_states"] = Q_rand_states
				obj["runs"] = Q_runs;
				obj["curr_it"] = curr_it;
				obj["eps"] = Q_eps;
				obj["alpha"] = Q_alpha;
				obj["gamma"] = Q_gamma;
				obj["count"] = Q_count;
				obj["Q"] = Q;

				train_file.seek(0);
				pickle.dump(obj,train_file,protocol=2);

				print("wrote training until now");

		## reset varaibles
		global grid, xs, ys, dirs, score, applepos;

		xs = np.copy(xs_orig);
		ys = np.copy(ys_orig);
		dirs = 0;
		score = snake_init_length;
		grid = np.copy(grid_orig);
		applepos = rand_apple_pos();
		Q_init();
		
		if (not TRAIN and curr_it % 200 == 0):
			print(avg_score/200)
			avg_score = 0

		run();

		avg_score += score;
PAUSE = False;
usr_FPS = 0;
def run():
	global PAUSE, usr_FPS, xs, ys, applepos, score, dirs;

	while True:
		if not DEBUG:
			if USER:
				clock.tick(20);
			else:
				clock.tick(usr_FPS);
			for e in pygame.event.get():
				if e.type == QUIT:
					sys.exit(0)
				elif e.type == KEYDOWN:
					if USER and e.key == K_UP and dirs != 0:
						dirs = 2
					elif USER and e.key == K_DOWN and dirs != 2:
						dirs = 0
					elif USER and e.key == K_LEFT and dirs != 1:
						dirs = 3;
					elif USER and e.key == K_RIGHT and dirs != 3:
						dirs = 1;
					elif e.key == K_SPACE:
						if PAUSE:
							usr_FPS = FPS;
							PAUSE = False;
						else:
							if usr_FPS == 0:
								usr_FPS = 15;
							elif usr_FPS == 15:
								usr_FPS = 1; 
							elif usr_FPS == 1:
								PAUSE = True;
		
		if not PAUSE:
			## ai here
			if(ALGO_PARAMS==None):
				dirs = ALGO();
			else:
				dirs = ALGO(ALGO_PARAMS);

			move(xs,ys,dirs,True);

			## chekc collisions (self, apple, boundries)
			if(check_self(xs,ys)):
				return;
			if check_apple(xs,ys):
				score+=1;
				xs = np.append(xs,grid_size*obj_size + 100);
				ys = np.append(ys,grid_size*obj_size + 100);
				applepos=rand_apple_pos();
			
			if check_boundries(xs, ys): 
				return;

		if not DEBUG:
			s.fill((255, 255, 255));
			s.blit(img_head, (xs[0],ys[0]));
			
			for i in range(1, len(xs)):
				s.blit(img_body, (xs[i], ys[i]))
			s.blit(appleimage, applepos);
			t=f.render("length: " + str(score), True, (0, 0, 0));
			s.blit(t, (10, 10));
			#t=f.render("eps: {0:.4f}".format(Q_eps), True, (0,0,0));
			#s.blit(t, (10, 30));
			
			## below is for debugging grid
			#for i in range(grid_size):
			#	for j in range(grid_size):
			#		curr = grid[i][j]
			#		if curr == 1:
			#			s.blit(img_body, (i*obj_size,j*obj_size))
			#		elif curr == 2:
			#			s.blit(appleimage, applepos)
			
			pygame.display.update()

### define ai algos ###

def ai_weighted_rand_walk(params):
	
	w = params[0]; # weights
	s = params[1]; # smart or not (crash into self/walls ok?)
	
	tries = [(forward,w[0]), (left_turn,w[1]), (right_turn,w[2])] # forward, left, right

	while(len(tries)>0):
		fake_xs = np.copy(xs);
		fake_ys = np.copy(ys);
		fake_dirs = dirs;
		
		## weighted choice of what to do next
		total = sum(w for c,w in tries);
		r = random.uniform(0, total);
		upto = 0;
		for c,w in tries:
				if upto + w >= r:
						func = c;
						weight = w;
						break;
				upto += w;

		fake_dirs = func(fake_dirs);
		move(fake_xs,fake_ys,fake_dirs,False);
		
		if not s:
			return fake_dirs;

		if not (check_boundries(fake_xs,fake_ys) or check_self(fake_xs,fake_ys)):
			return fake_dirs;
		
		tries.remove((func,weight));

	## at this point we are in a corner and whatever choice will lead us to die
	## might as well just return the original direction
	return dirs;

def ai_smart():
	tries = [forward, left_turn, right_turn];
	work = [];

	while(len(tries)>0):
		fake_xs = np.copy(xs);
		fake_ys = np.copy(ys);
		fake_dirs = dirs;

		func = random.choice(tries);
		fake_dirs = func(fake_dirs);

		move(fake_xs, fake_ys, fake_dirs, False);

		if(check_boundries(fake_xs,fake_ys)):
			tries.remove(func);
			continue;

		if(check_self(fake_xs,fake_ys)):
			tries.remove(func);
			continue;

		dist = np.sqrt(pow(fake_xs[0]-applepos[0],2) + pow(fake_ys[0]-applepos[1],2));
		work.append([dist,fake_dirs]);
		tries.remove(func);

	if(len(work)>0):
		ind = 0;
		min_dist = 10000000;
		
		for i in range(len(work)):
			if work[i][0] < min_dist:
				ind = i;
				min_dist = work[i][0];

		return work[ind][1];

	## at this we are in a corner and whatever choice will lead us to die 
	## might as well just return the original direction
	return dirs;

# Q learning AI
Q = {};
Q_runs = np.array([]);
Q_actions = [forward, left_turn, right_turn];
Q_eps = .2;
Q_alpha = .5;
Q_gamma = .8;
Q_count = 0;
Q_turns = np.array([0,0,0]); # -1 is left, 1 is right
Q_rand_states = None

def Q_init():
	global Q_turns;
	
	Q_turns = np.array([0,0,0]);

### find apple quadrant relative to the snake's head
def Q_apple_quad(dirs):
	dx = 1 if applepos[0] >= xs[0] else -1
	dy = 1 if grid_size*obj_size - applepos[1] >= grid_size*obj_size - ys[0] else -1;

	if dirs ==   0: #down
		qx = -dx;
		qy = -dy;
	elif dirs == 1: #right
		qx = -dy;
		qy = dx;
	elif dirs == 2: #up (does nothing)
		qx = dx;
		qy = dy;
	elif dirs == 3: #left
		qx = dy;
		qy = -dx;

	return (qx,qy);

def Q_get_state(dirs):
	spc = [0,0,0] # forward, left, right
	spc_dist = [10000000, 10000000, 10000000];
	fake_dirs = None;

	for j in range(3):
		fake_xs = np.copy(xs);
		fake_ys = np.copy(ys);
		fake_dirs = dirs;
	
		fake_dirs = Q_actions[j](fake_dirs);
		move(fake_xs, fake_ys, fake_dirs, False);
		
		if(check_boundries(fake_xs, fake_ys) or check_self(fake_xs, fake_ys)):
			spc[j] = -1;

		if check_apple(fake_xs, fake_ys):
			spc[j] = 1;

		spc_dist[j] = np.sqrt(pow(fake_xs[0]-applepos[0],2) + pow(fake_ys[0]-applepos[1],2));

	(qx, qy) = Q_apple_quad(dirs);
	state = (spc[0],spc[1],spc[2],Q_turns[0], Q_turns[1], Q_turns[2], qx,qy);

	return { "spc" : spc, "spc_dist" : spc_dist, "state" : state};

## currently not used 
## plan is to figure out reward for all actions at once to optimize training
def Q_get_rewards(spc):
	rewards = [0,0,0];
	episode_ended = [False, False, False];
	## get reward from next state
	## action corresponds to the action the snake will take
	## spc[action] corresponds to the outcome in next state
	for i in range(3):
		if spc[i] == -1:                 # crashed
			reward[i] = -1000;
			episode_ended[i] = True;
		elif spc[i] == 1:                # ate apple
			reward[i] = 500;
		elif spc_dist[i] < dist:         # closer to apple
			reward[i] = 0;
		else:                                 # anything else
			reward[i] = 0;

def ai_qlearn():
	global Q, Q_count, Q_eps, Q_turns;
	
	## due to artifacts of implementation, instead of having a current state
	## and previous state, like the Q-learn algorithm requires, we instead have
	## a current state and a next state, where the current state effectivley 
	## acts like the previous state, and the next state acts as the current state
	## in terms of the Q-Learn Algo.

	## epsilon greedy exploration
	Q_count += 1;
	if Q_count > 10000:
		Q_count = 0;
		Q_eps -= Q_eps/20;
		#if Q_eps < .05:
		#	Q_eps = 0

	## init some variables
	episode_ended = False;
	reward = 0;
	distance = 10000000;
	action = -1;

	## get current state
	state_space = Q_get_state(dirs);
	state = state_space["state"];
	spc = state_space["spc"];
	spc_dist = state_space["spc_dist"];

	# calculate distance to apple
	dist = np.sqrt(pow(xs[0]-applepos[0],2) + pow(ys[0]-applepos[1],2));

	## take best action (or explore)
	if state not in Q:
		Q[state] = [10,10,10]; # assume optimistic actions

	q = Q[state];
	maxQ = max(q);

	if random.random() < Q_eps:
		action = random.choice([0,1,2]);
	else:
		best = [i for i,x in enumerate(q) if x == maxQ];
		action = random.choice(best);

	# get next action
	func = Q_actions[action];
	fake_dirs = func(dirs);

	# change next state
	if action == 1:
		Q_turns[2] = Q_turns[1];
		Q_turns[1] = Q_turns[0];
		Q_turns[0] = -1;
	elif action == 2:
		Q_turns[2] = Q_turns[1];
		Q_turns[1] = Q_turns[0];
		Q_turns[0] = 1;

	## get reward from next state
	## action corresponds to the action the snake will take
	## spc[action] corresponds to the outcome in next state
	if spc[action] == -1:                 # crashed
		reward = -1000;
		episode_ended = True;
	elif spc[action] == 1:                # ate apple
		reward = 500;
	elif spc_dist[action] < dist:         # closer to apple
		reward = 10;
	else:                                 # anything else
		reward = -25;
	
	if (Q_turns[0]==-1 and Q_turns[1]==-1 and Q_turns[2]==-1 and action==1) or (Q_turns[0]==1 and Q_turns[1]==1 and Q_turns[2]==1 and action==2):
		reward -= 0;

	state_next = None;
	## update q of current state
	if episode_ended:
		Q[state][action] += Q_alpha * (reward - Q[state][action]);
	else:
		state_next = Q_get_state(fake_dirs)["state"];
		if state_next not in Q:
			Q[state_next] = [10,10,10];
		
		Q[state][action] += Q_alpha * (reward + Q_gamma * max(Q[state_next]) - Q[state][action]);

	return fake_dirs;

## 'ai' which lets the user play, basically identity function
def ai_user():
	return dirs;

### set environment ###
DEBUG = False;
USER = False;
TRAIN = False;
ALGO = ai_weighted_rand_walk;
ALGO_PARAMS = [1/3,1/3,1/3]; # completley random walk
FPS = 0;

for i in range(1,len(sys.argv)):
	curr = sys.argv[i];
	if curr == "-d":
		DEBUG = True;
	elif curr == "-r":
		ALGO = ai_weighted_rand_walk;
		ALGO_PARAMS = [[1/3,1/3,1/3], False];
	elif curr == "-wr":
		ALGO = ai_weighted_rand_walk;
		ALGO_PARAMS = [[.8,.1,.1], False];
	elif curr == '-sr':
		ALGO = ai_weighted_rand_walk;
		ALGO_PARAMS = [[1/3,1/3,1/3], True];
	elif curr == '-swr':
		ALGO = ai_weighted_rand_walk;
		ALGO_PARAMS = [[.8,.1,.1], True];
	elif curr == "-s":
		ALGO = ai_smart;
		ALGO_PARAMS = None;
	elif curr == "-q":
		ALGO = ai_qlearn;
		ALGO_PARAMS = None;
	elif curr == "-usr":
		ALGO = ai_user;
		ALGO_PARAMS = None;
		USER = True;
	elif curr == "-t":
		TRAIN = True;
	elif curr.isdigit():
		FPS = float(curr);
	else:
		raise Exception("Unrecognized parameter " + curr)

### set up game variables ###

obj_size = 10;
grid_size = 10;
grid_orig = np.zeros((grid_size,grid_size));

snake_head_start =  (np.floor(grid_size/2)*obj_size,np.floor(grid_size/2)*obj_size);
snake_init_length = 5;

xs_orig = np.array([snake_head_start[0]]);
ys_orig = np.array([snake_head_start[1]]);

grid_orig[xs_orig[0]/obj_size][ys_orig[0]/obj_size] = 1;

for i in range(1,snake_init_length):
	xs_orig = np.append(xs_orig, snake_head_start[0]);
	ys_orig = np.append(ys_orig, snake_head_start[1] - i * obj_size);
	grid_orig[xs_orig[0]/obj_size][ys_orig[i-1]/obj_size] = 1;

xs = np.array([]);
ys = np.array([]);
grid = np.zeros((grid_size,grid_size));

dirs = 0;
score = 0;
applepos = (0,0);

### set up non debug environment ###

if not DEBUG:
	pygame.init();
	s=pygame.display.set_mode((grid_size*obj_size, grid_size*obj_size));
	pygame.display.set_caption('SnakeAI');
	appleimage = pygame.Surface((obj_size, obj_size));
	appleimage.fill((0, 255, 0));
	img_body = pygame.Surface((obj_size, obj_size));
	img_body.fill((255, 0, 0));
	img_head = pygame.Surface((obj_size, obj_size));
	img_head.fill((125, 0, 0));
	f = pygame.font.SysFont('Arial', 20);
	clock = pygame.time.Clock()

### run game
init_game();
