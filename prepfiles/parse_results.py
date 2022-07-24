#!/usr/bin/python


""" @author - Payal Chatterjee, June 2019

This file parses the results in my pure_solv pipeline to generate the final results.

Usage :

python parse_results.py ${resi} ${tempr} ${scan}
 
"""

import sys

resi=sys.argv[1]
tempr=sys.argv[2]
scan=sys.argv[3]

rf=open('results_'+resi+'_t'+tempr+'_scan'+scan+'.txt', 'r')
run=[]
hvap=[]
vol=[]
diel=[]
for lines in rf:
	line=lines.strip()
	if 'run' in line:
		run.append(line)
	elif 'cu.A' in line:
		vol.append(line.split()[2])
	elif 'KCal' in line:
		hvap.append(line.split()[4])
	elif 'Dielectric' in line:
		diel.append(line.split()[1])

with open('results_'+resi+'_t'+tempr+'_scan'+scan+'.csv', 'w+') as outf:
	outf.write(",".join(["run", "rep", "vol", "hvap", "diel"+'\n']))
	for (r,v,h,e) in zip(run,vol,hvap,diel):
 		outf.write(",".join([r,v,h,e+'\n']))	
