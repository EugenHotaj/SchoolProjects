import pickle
import numpy as np

train_file = open("train","wb")

# initialize writing object
obj = {}
obj["curr_it"] = 0
obj["eps"] = .3
obj["alpha"] = .5
obj["gamma"] = .5
obj["count"] = 0
obj["runs"] = np.array([])
obj[0] = {} # Q dictionary at every t runs

pickle.dump(obj,train_file,pickle.HIGHEST_PROTOCOL)
