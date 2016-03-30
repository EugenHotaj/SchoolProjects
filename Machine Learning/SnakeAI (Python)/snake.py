import pygame;
import random;
import sys;
import numpy as np;
from pygame.locals import *;

# set environment
DEBUG = False;
if len(sys.argv)>1 and sys.argv[1] == "-d":
	DEBUG = True;

obj_size = 10;
snake_head_start =  (280,280);
snake_init_length = 5;

xs_orig = np.array([snake_head_start[0]]);
ys_orig = np.array([snake_head_start[1]]);

for i in range(1,snake_init_length):
	xs_orig = np.append(xs_orig, snake_head_start[0]);
	ys_orig = np.append(ys_orig, snake_head_start[1] - i * obj_size);
	
xs = np.array([]);
ys = np.array([]);
dirs = 0;
score = 0;
applepos = (0,0);

pygame.init();
s=pygame.display.set_mode((600, 600));
pygame.display.set_caption('Snake');
appleimage = pygame.Surface((10, 10));
appleimage.fill((0, 255, 0));
img = pygame.Surface((20, 20));
img.fill((255, 0, 0));
f = pygame.font.SysFont('Arial', 20);

clock = pygame.time.Clock()

def collide(x1, x2, y1, y2, w1, w2, h1, h2):
	if x1+w1>x2 and x1<x2+w2 and y1+h1>y2 and y1<y2+h2:
		return True
	else:
		return False

def init_game():
	global xs, ys, dirs, score, applepos;
	xs = np.copy(xs_orig);
	ys = np.copy(ys_orig);
	dirs = 0;
	score = 0;
	applepos = (random.randint(0, 29)*20+5, random.randint(0,29)*20+5);
	run();
	
def left_turn():
	return;

def right_turn():
	return;

def run():
	global clock, xs, ys, applepos, dirs, s, f, score, appleimage, img, f;
	while True:
		clock.tick(10)
		for e in pygame.event.get():
			if e.type == QUIT:
				sys.exit(0)
			elif e.type == KEYDOWN:
				if e.key == K_UP and dirs != 0:
					dirs = 2
				elif e.key == K_DOWN and dirs != 2:
					dirs = 0
				elif e.key == K_LEFT and dirs != 1:
					dirs = 3
				elif e.key == K_RIGHT and dirs != 3:
					dirs = 1
		i = len(xs)-1
		while i >= 2:
			if collide(xs[0], xs[i], ys[0], ys[i], 20, 20, 20, 20):
				init_game();
			i-= 1
		if collide(xs[0], applepos[0], ys[0], applepos[1], 20, 10, 20, 10):
			score+=1;
			xs = np.append(xs,700);
			ys = np.append(ys,700);
			applepos=(random.randint(0,29)*20+5,random.randint(0,29)*20+5);
		if xs[0] < 0 or xs[0] > 580 or ys[0] < 0 or ys[0] > 580: 
			init_game();
		i = len(xs)-1
		while i >= 1:
			xs[i] = xs[i-1];
			ys[i] = ys[i-1];
			i -= 1
		if dirs==0:
			ys[0] += 20
		elif dirs==1:
			xs[0] += 20
		elif dirs==2:
			ys[0] -= 20
		elif dirs==3:
			xs[0] -= 20	
		s.fill((255, 255, 255))	
		for i in range(0, len(xs)):
			s.blit(img, (xs[i], ys[i]))
		s.blit(appleimage, applepos);
		t=f.render(str(score), True, (0, 0, 0));
		s.blit(t, (10, 10));
		pygame.display.update()

init_game();

					
					
			


