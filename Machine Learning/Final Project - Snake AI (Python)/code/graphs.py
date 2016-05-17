import pickle
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import patches as mpatches

## values from tests avg over 200 iterations
## const since no learning occurs 
## extrapolate over all of Q_learn's runs 
bench_sr = 6.85
bench_swr = 9.265
bench_s = 35.745

f = open("train","rb")
obj = pickle.load(f)

tot_its = 10000
ep_size = 200

## initialize graphs
xs = np.array([0])
ys_sr = np.array([6.65])
ys_swr = np.array([9.265])
ys_s = np.array([35.745])
ys_q = np.array([5])

for i in range(int(tot_its/ep_size)):
	xs = np.append(xs,i * ep_size)
	ys_sr = np.append(ys_sr, bench_sr)
	ys_swr = np.append(ys_swr, bench_swr)
	ys_s = np.append(ys_s, bench_s)
	ys_q = np.append(ys_q, obj["runs"][i])

plt.figure(1)

rp = mpatches.Patch(color='r', label='Rand')
bp = mpatches.Patch(color='b', label='Eucl')
gp = mpatches.Patch(color='g', label='WRand')
mp = mpatches.Patch(color='m', label='QLearn')
plt.legend(handles=[rp,bp,gp,mp])

plt.title('Q Learning Performance on a 20x20 Grid')
plt.ylabel('Averege Maximum Snake Length')
plt.xlabel('Numer of Games')

lines = plt.plot(xs,ys_sr,'r',   xs,ys_swr,'g',   xs,ys_s,'b',   xs,ys_q,'m')
plt.setp(lines, linewidth=2.0)

plt.show()
