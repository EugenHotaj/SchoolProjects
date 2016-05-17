import pickle
import random 
import numpy as np

def build_states():
	states ={}
	#for i in range(5):
	#	state =[int(random.random()*3-1), int(random.random()*3-1), int(random.random()*3-1)]
	#	for j in range(obj["num_turns"]):
	#		state.append(int(random.random()*3-1))
	#	state.append(-1 if random.random() < .5 else 1)
	#	state.append(-1 if random.random() < .5 else 1)
	#	states[tuple(state)] = np.array([])
	

	# hand picked for now, above code generates impossible states
	states[(1,0,0,1,-1,-1,-1,1)] = np.array([0]);
	states[(0,0,0,1,1,1,1,1)] = np.array([0]);
	states[(0,0,0,1,-1,0,1,1)] = np.array([0]);
	
	return states

obj = {}
obj["curr_it"] = 0
obj["eps"] = .3
obj["alpha"] = .5
obj["gamma"] = .8
obj["count"] = 0
obj["runs"] = np.array([]) 
obj["num_turns"] = 3
obj["Q"] = {}
obj["rand_states"] = build_states()

train_file = open("train","wb")

pickle.dump(obj,train_file,protocol=2)
