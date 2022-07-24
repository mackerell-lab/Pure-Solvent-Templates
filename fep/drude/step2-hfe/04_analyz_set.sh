#!/bin/bash

#echo "run # ? (1,2,3...)"
#read run
#if [ ! -e run${run} ]; then
#    echo "Error: There is no directory --> run${run}"
#    exit
#fi
echo enter resname
read res
echo enter paramfile
read paramfile


#runlist=$(cat alkenes_final_parameters_top28.csv | awk 'NR>1{ print $1}' | cut -f 1 -d ',')
runlist=$(cat $paramfile | awk -F',' 'NR>1{ print $1}' )

for run in ${runlist[@]};do
cd ${res}/run${run}
#for res in `cat list`
for rep in `seq 1 1`;do
	cd rep${rep}
    echo ${res}
    cd vac
    echo "--- vac    " `grep ABNORMAL fp*_l*out 2> /dev/null | wc` `grep NORMAL fp*_l*out 2> /dev/null | wc`
    fail=`grep ABNORMAL fp*_l*out 2> /dev/null | wc -l`
    pass=`grep NORMAL fp*_l*out 2> /dev/null | wc -l`
    if [ $fail -eq 0 ] && [ $pass -eq 40 ]; then
	echo "    Running analysis"
	qsub runextr.job
	#sleep 300
    else
	if [ -e job.1 ]; then
	    echo "    Already finished analysis"
	else
	    echo "    Waiting for simulations to finish"
	fi
    fi
    cd ../water
    echo "--- water  " `grep ABNORMAL fp*_l*out 2> /dev/null | wc` `grep NORMAL fp*_l*out 2> /dev/null | wc`
    fail=`grep ABNORMAL fp*_l*out 2> /dev/null | wc -l`
    pass=`grep NORMAL fp*_l*out 2> /dev/null | wc -l`
    if [ $fail -eq 0 ] && [ $pass -eq 40 ]; then
	echo "    Running analysis"
	qsub runextr.job
	#sleep 300
    else
        if [ -e job.1 ]; then
            echo "    Already finished analysis"
	else
            echo "    Waiting for simulations to finish"
	fi
    fi
    cd ../LRC
    echo "--- LRC    " `grep ABNORMAL ana*out 2> /dev/null | wc` `grep NORMAL ana*out 2> /dev/null | wc`
    fail=`grep ABNORMAL ana*out 2> /dev/null | wc -l`
    pass=`grep NORMAL ana*out 2> /dev/null | wc -l`
    if [ $fail -eq 0 ] && [ $pass -eq 1 ] && [ -e energy_lrc.txt ]; then
	echo "    Already finished analysis"
    else
        echo "    Waiting for simulations to finish"
    fi
    cd ../../
done
cd ../../
done
