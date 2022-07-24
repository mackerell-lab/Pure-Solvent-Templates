#!/bin/bash

echo enter resi
read res

echo enter paramfile
read paramfile

runlist=$(cat $paramfile | awk -F',' 'NR>1{ print $2}' )
#runlist=('add')
echo ${res}
cd ${res}

for set in ${runlist[@]};do
cd run${set}
for rep in `seq 1 3`;do
cd rep${rep}
echo "resid dG_wat dG_vac zFΦ dS_corr LRC dG_real Units" | awk '{print $1,"\t",$2,"\t",$3,"\t",$4,"\t","\t",$5,"\t",$6,"\t","\t",$7,"\t",$8}'

   cd vac
   echo "vac: `pwd`"
    echo "--- vac    " `grep ABNORMAL fp*_l*out 2> /dev/null | wc` `grep NORMAL fp*_l*out 2> /dev/null | wc`
    fail=`grep ABNORMAL fp*_l*out 2> /dev/null | wc -l`
    pass=`grep NORMAL fp*_l*out 2> /dev/null | wc -l`
    if [ $fail -eq 0 ] && [ $pass -eq 40 ]; then
#	echo "    Running analysis"
#	qsub runextr.job
	sleep 1
    else
	if [ -e job.1 ]; then
#	    echo "    Already finished analysis"
	    vac=1
	else
	    echo "$res    Waiting for simulations to finish"
	fi
    fi
  cd ../water
  echo "water: `pwd`"
    echo "--- water  " `grep ABNORMAL fp*_l*out 2> /dev/null | wc` `grep NORMAL fp*_l*out 2> /dev/null | wc`
    fail=`grep ABNORMAL fp*_l*out 2> /dev/null | wc -l`
    pass=`grep NORMAL fp*_l*out 2> /dev/null | wc -l`
    if [ $fail -eq 0 ] && [ $pass -eq 40 ]; then
#	echo "    Running analysis"
#	qsub runextr.job
	sleep 1
    else
        if [ -e job.1 ]; then
#            echo "    Already finished analysis"
	    wat=1
	else
            echo "$res    Waiting for simulations to finish"
	fi
    fi
  cd ../LRC
  echo "LRC: `pwd`"
    echo "--- LRC    " `grep ABNORMAL ana*out 2> /dev/null | wc` `grep NORMAL ana*out 2> /dev/null | wc`
    fail=`grep ABNORMAL ana*out 2> /dev/null | wc -l`
    pass=`grep NORMAL ana*out 2> /dev/null | wc -l`
    if [ $fail -eq 0 ] && [ $pass -eq 1 ] && [ -e energy_lrc.txt ]; then
#	echo "    Already finished analysis"
	lrc=1
    else
        echo "$res    Waiting for simulations to finish"
    fi
   cd ..
    echo "vac $vac wat $wat lrc $lrc"
    if [ $vac -eq 1 ] && [ $wat -eq 1 ] && [ $lrc -eq 1 ]; then
	if [ ! -e charge.txt ]; then
	    echo $res
	    echo '--->'
	    echo "what is the charge on your molecule? (e.g. 2/1/0/-1/-2)"
	    read rep
	    echo "${rep}" > charge.txt
	fi
	./calc.run < charge.txt > dG_real.txt
#	grep -A 2 "Units" dG_real.txt
	value=`grep "kcal" dG_real.txt`
	echo "${res} ${value}" | awk '{print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$6,"\t",$7,"\t",$8}'
    fi
    vac=0
    wat=0
    lrc=0
	#cd ../
	echo "rep: `pwd`"
cd ../
echo "run: `pwd`"
done
cd ../
echo "resi `pwd`"
done
cd ../
echo "fep: `pwd`"
echo `pwd`
