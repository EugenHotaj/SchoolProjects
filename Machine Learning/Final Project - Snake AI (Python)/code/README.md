# SnakeAI

AI to play snake using reinforcement learning, namely Q-learning.

To run: 

    python snake.py [-d] [-t] [-(algo)]

Params:

    -d : debug mode, runs with no GUI, meant to be used when training the learning algorithm
    -t : train mode, the knowledge learned from the algorithm is written to the file "train"
    -(algo):
       -r   : random walk             , snake crashes into self, walls
       -sr  : "smart" random          , snake doesn't crash into self, walls
       -wr  : weighted random         , snake only turns 20% of the time, crashes into self, walls
       -swr : "smart" weighted random , snake only turns 20% of the time, doesn't crash into self, walls
       -s   : euclidian distance ai   , snake always chooses action which will lead it closer to the apple, doesn't crash into self, walls
       -q   : qlearn                  , snake moves according to learned actions

WARNING: `reinit_training.py` will reset the snake's learned progress. 
    
Dependencies
* pygame
* numpy
* pickle
