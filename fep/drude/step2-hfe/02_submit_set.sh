#!/bin/bash

#echo "set # ? (1,2,3...)"
#read set


echo enter resilistfile
read resilistfile
echo enter paramfile
read paramfile
resilist=$(cat $resilistfile)
runlist=$(cat $paramfile | awk -F',' 'NR>1{ print $2}' )
#runlist='add'

for resi in ${resilist[@]};do
cd ${resi};
for set in ${runlist[@]};do
echo run${set}
cd run${set}
	for i in `seq 1 1`;do
	cd rep${i}
    cd vac
    if [[ ${i} == 1 ]];then
    ./fep.run
	fi
	
    #echo "vac: `pwd`"
    #sleep 400
    cd ../water
    ./fep.run
    
    #echo "water: `pwd`"
    cd ../LRC
    if [[ ${i} == 1 ]];then
    qsub submit_lrc
	fi
    #echo "LRC: `pwd`"
    cd ../
    sleep 120
	
cd ../
done
cd ../
done
cd ../
done
