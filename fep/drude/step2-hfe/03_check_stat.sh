#!/bin/bash

echo enter res
read res

echo enter paramfile
read paramfile
#runlist=$(cat alkenes_final_parameters_top28.csv | awk 'NR>1{ print $1}' | cut -f 1 -d ',')
runlist=$(cat $paramfile | awk -F',' 'NR>1{ print $1}' )
#if [ ! -e run${set} ]; then
#    exit
#fi
for set in ${runlist[@]};do
cd ${res}/run${set}

#for res in `cat list`
for rep in `seq 1 1`;do
    echo run${set}
	cd rep${rep}
    cd vac
    echo "--- vac    " `grep ABNORMAL fp*_l*out 2> /dev/null | wc` `grep NORMAL fp*_l*out 2> /dev/null | wc`
    cd ../water
    echo "--- water  " `grep ABNORMAL fp*_l*out 2> /dev/null | wc` `grep NORMAL fp*_l*out 2> /dev/null | wc`
    cd ../LRC
    echo "--- LRC    " `grep ABNORMAL ana*out 2> /dev/null | wc` `grep NORMAL ana*out 2> /dev/null | wc`
    cd ../../
done
cd ../../
done
