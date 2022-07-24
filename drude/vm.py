#! /usr/bin/python
# compute molecular volume
# Vm = <VOLUme> / number of molecules in the box
# Jing Huang, Oct. 2014
# Modified by Payal Chatterjee, June 2019

import string,sys,math

try:
        xfile = open(sys.argv[1],'r')
except IOError:                     #catch exception
        print ('Files do not exist!\n')


number=int(sys.argv[2])


x1=[]
for line in xfile.readlines():
    x1.append(float(string.split(line)[0])**3)

vbox=sum(x1)/len(x1)

avogadro=6.023e23
print "Emperical Vol:", vbox/float(number), 'cu.A'
#print "Emperical Vol:", vbox/float(number)*avogadro*1e-24, 'cu.cm'

