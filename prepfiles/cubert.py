#!/usr/bin/python

"""

@author  : Payal Chatterjee, June 2019

This script calculates the final boxsize from the last frame of a NAMD trajectory.

Requirements : python3 and the path of the namd trajectory (I use the vars_box.str file inside the analysis folder)

See the templates for clarity!

Usage : from within the prep_reps_drude.sh file :

python cubert.py run${i}/rep${j}/analysis/vars_cond.str


"""



import numpy as np
np.set_printoptions(precision=2)

f = open('vol', 'r')
newf = open('boxsize', 'w')
fhalf = []
box = []
for lines in f:
	line=lines.split(":")
	fhalf.append(line[0])
	vol=line[1]
	boxsize=np.float64(vol) ** (1. / 3)
	box.append(np.float32(boxsize))

for i in range(len(fhalf)): 
	newf.write(str(fhalf[i])+str(np.float32(box[i])) + "\n")
newf.close()
