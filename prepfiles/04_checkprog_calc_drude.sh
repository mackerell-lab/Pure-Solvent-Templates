#!/bin/bash

charmm=/opt/mackerell/apps/charmm/serial/c44b2-serial
workdir=`pwd`
echo enter resfile
read resfile
resilist=$(cat $resfile)

#### used when changing multiple LJ parameters together - such that each is labelled as a "run"
echo enter paramfile
read paramfile

#### be careful here as your csv file might look a bit different - $2 indicates the runid
runlist=$(cat $paramfile | awk -F',' 'NR>1{print $2}')

#### if your runlist is in sequence, comment the above and rather use this list
#runlist=`seq $2 $3`
cwd=`pwd`
echo "action: e.g charmm, getcharmbox, checkboxes, step1, convert, step2, getbox, analysis, checkprog, calc"
read action

for resi in ${resilist[@]};do
cd ${resi}/drude
#rm toppar.str
for tempr in t[0-9]*;do
if [[ ${tempr} != "t000" ]];then
cd ${tempr}

echo "=======$resi/${tempr}======"
if [[ "$action" == "charmm" ]];then
	for i in ${runlist[@]};do cd run${i} ;for rep in `seq 1 3`;do 
	cd rep${rep};
	sed -i "s/%run%/$i/g" job_step1.sh;sed -i "s/%rep%/$rep/g" job_step1.sh;
	sed -i "s/R_init/R/g" job_step1.sh;
	qsub job_step1.sh;cd ../; done;cd ../;
done
elif [[ "$action" == "getcharmbox" ]];then
	for i in ${runlist[@]};do for j in `seq 1 3`;do #cp ${cwd}/namd-equil.conf run${i}/rep${j}/ ;
	sed -i "s/%resi%/$resi/g" run${i}/rep${j}/namd-equil.conf
	temp=$(grep "set tempr" run${i}/rep${j}/vars_box.str | awk '{print $3}')
	sed -i "s/%temp%/$temp/g" run${i}/rep${j}/namd-equil.conf
    xtala=$(grep "LATTICE SIZE:" run${i}/rep${j}/step1-boxequil/${resi}.box.1.crd | awk '{print $4}'); 
	echo "run${i}/rep${j}:  temp is $temp; tempr is $tempr"
    xtalprec=$(printf "%.2f\n" $xtala)
	cp runfinal/rep${j}/${resi}_box_equil.pdb run${i}/rep${j}/
	sed -i "s/%boxsize%/$xtalprec/g" run${i}/rep${j}/namd-equil.conf;
	sed -i "s/%namdseed%/$RANDOM/g" run${i}/rep${j}/namd-equil.conf; done; done
elif [[ "$action" == "checkboxes" ]];then
	for i in ${runlist[@]};do cd run${i} ;for rep in `seq 1 3`;do 
	cd rep${rep};
	echo run${i}/rep${rep}
	grep "set boxsize" namd-equil.conf;
	rm step1-boxequil/*.vel
	cd ../; done;cd ../;done
elif [[ "$action" == "writepsf" ]];then
	for i in ${runlist[@]};do cd run${i} ;for rep in `seq 1 3`;do cd rep${rep};cp ${cwd}/${resi}.str . ;cp ${cwd}/${resi}.str ${cwd}/toppar_drude/;
	cp ${cwd}/writepsf.inp .
	$charmm vars=vars_box consts=consts_box -i writepsf.inp > writepsf.out;cd ../; done;cd ../;done

elif [[ "$action" == "step1" ]];then
	for i in ${runlist[@]};do cd run${i} ;for rep in `seq 1 3`;do cd rep${rep};qsub job_namd.sh;cd ../; done;cd ../;
done
elif [[ "$action" == "convert" ]];then 
	for i in ${runlist[@]};do cd run${i} ; for rep in `seq 1 3`;do 
	cd rep${rep}; 
	cp toppar_drude/${resi}.str .
	#cp ${cwd}/toppar_drude.str .
	cp ${cwd}/writecrd.inp .
	#cp ${cwd}/consts_box.str .
	echo "generating crd of the last frame (set to 200) of namd-dcd"
	$charmm vars=vars_box consts=consts_box -i writecrd.inp > writecrd.out; 
	cd ../;done;cd ../;done
elif [[ "$action" == "step2" ]];then
	for i in ${runlist[@]};do cd run${i};for rep in `seq 1 3`;do cd rep${rep}/step2-monodata;
	sed -i "s/monoseed/monorseed/g" vars_mono.str
	sed -i "s/%monorseed%/$RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM $RADNOM$RANDOM/g" vars_mono.str
	sed -i "s/mpirun1 8/mpirun1 1/g" random*.job
	sed -i "s/parallel/serial/g" random*.job
	#sed -i "s/h_data=\!/h=\!/g" random*.job
	sed -i "s/%run%/$i/g" vars_mono.str
	sed -i "6 a \#\$ -l h=\!(n170|n171)" random*.job
	#cat random*.job
	
	bash qsub_random.sh 
	cd ../../;done;cd ../;    
	numjobs=$(qstat -u pchatter | wc -l )
	if [[ $numjobs -gt 500 ]];then
		sleep 120
	elif [[ $numjobs -gt 250 ]];then
		sleep 60
	elif [[ $numjobs -gt 200 ]];then
		sleep 30
	elif [[ $numjobs -le 100 ]];then
		sleep 20
	elif [[ $numjobs -le 50 ]];then
		sleep 5
	fi
	
	done
elif [[ "$action" == "getbox" ]];then

			rm vol boxsize 
	for i in ${runlist[@]};do 
		for j in `seq 1 3`;do
			cp ${cwd}/cubert.py .
			cp ${cwd}/ana_cond.inp run${i}/rep${j}/analysis/
			vol=$(grep -H "ENERGY:  100000" run${i}/rep${j}/namd-equil.out | awk '{print $19}' | tail -1)
			echo "run${i}/rep${j} : $vol" >> vol
    		python cubert.py run${i}/rep${j}/analysis/vars_cond.str
	done
	done
	while IFS= read -r hdr;do
	boxinfo=$(echo $hdr | awk '{print $1}')
	boxsize=$(echo $hdr | awk '{print $2}')
	boxprec=$(printf "%.2f\n" $boxsize)
	echo "$boxinfo $boxprec"
	sed -i "s;%box%;$boxprec;g" $boxinfo/analysis/vars_cond.str
	sed -i "s;%box%;$boxprec;g" $boxinfo/analysis/vars_gas.str
	sed -i "s;%box%;$boxprec;g" $boxinfo/analysis/vars_cond.str
	sed -i "s;%box%;$boxprec;g" $boxinfo/analysis/vars_gas.str
	done < boxsize


elif [[ "$action" == "analysis" ]];then
	for i in ${runlist[@]};do cd run${i};for rep in `seq 1 3`;do cd rep${rep}/analysis
	replacestr=$(grep "wrkdir=" anacond.sh)
	thisdir=`pwd`
#	sed -i 's;'"$replacestr"';wrkdir='"$thisdir"';g' anacond.sh
#	sed -i 's;'"$replacestr"';wrkdir='"$thisdir"';g' anagas.sh
    cp ${cwd}/ana_cond.inp .
	sed -i "s/%run%/$i/g" vars*.str
	sed -i 's;workdir;wrkdir;g' anacond.sh
	sed -i 's;workdir;wrkdir;g' anagas.sh
	if [ -d "anagas_${resi}" ]; then echo "gas phase dir present"; echo "===run${i}/rep${rep}====";echo "removing already present dir!!"; rm -r anagas_${resi} g${resi}*; echo "submitting gas again";
	qsub anagas.sh;else echo "====run${i}/rep${rep}===";qsub anagas.sh;fi
	
	if [ -d "anacond_${resi}" ]; then echo "cond. phase dir present"; echo "===run${i}/rep${rep}====";echo "removing already present dir!!"; rm -r anacond_${resi} C${resi}*; echo "submitting again";
	qsub anacond.sh;else echo "====run${i}/rep${rep}===";qsub anacond.sh;fi
	
	cd ../../
    done
cd ../
	numjobs=$(qstat -u pchatter | grep ${resi} | wc -l )
	if [[ $numjobs -gt 200 ]];then
		sleep 80
	elif [[ $numjobs -gt 100 ]];then
		sleep 50
	elif [[ $numjobs -gt 50 ]];then
		sleep 30
	else
	sleep 0
	fi
done

###########################
elif [[ "$action" == "checkprog" ]];then 
	echo "which step do you want to check prog for step1, convert, step2, analines, analysis?"
	read -r prog
	if [[ "$prog" == "charmm" ]];then	
	#for i in ${runlist[@]};do for j in `seq 1 3`;do grep -H "LATTICE SIZE:" run${i}/rep${j}/step1-boxequil/${resi}.box.1.crd;done; done
	for i in ${runlist[@]};do for j in `seq 1 3`;do xtala=$(grep "LATTICE SIZE:" run${i}/rep${j}/step1-boxequil/${resi}.box.1.crd | awk '{print $4}'); if (( $(echo $xtala '<' 50.0 | bc -l) ));then echo "run$i/rep$j : $xtala";fi; done; done

	elif [[ "$prog" == "step1" ]];then	
	for i in ${runlist[@]};do for j in `seq 1 3`;do step=$(grep "ENERGY:" run${i}/rep${j}/namd*.out | tail -n 1 | awk '{print $2}');if [[ "$step" != "20000000" ]];then echo "$step check run${i}/rep${j}";echo $step
	else echo "run${i}/rep${j}: ok";
	fi;done; done



	elif [[ "$prog" == "convert" ]];then
	for i in ${runlist[@]};do 
	for j in `seq 1 3`;do 
	grep -H "TERMINATION" run${i}/rep${j}/writecrd.out
	done
	done

	elif [[ "$prog" == "step2" ]];then	
	for i in ${runlist[@]};do cd run${i} ; for rep in `seq 1 3`;do cd rep${rep}; cd step2-monodata; echo "==========run${i}/rep${rep}===STEP2==========" ; for job in `seq 1 12`;do 
	echo "run${i}/rep${rep}"
	#grep -H "TERMINATION" step2-monomer.${job}.out ;
	done; 
	cnt=$(grep -H " NORMAL TER" step2*.out | wc -l);
	echo $cnt;if [[ $cnt -lt 12 ]];
	then sed -i "6 a \#\$ -l h=\!(n170|n171)" random*.job
	sed -i "s/mpirun1 8/mpirun1 1/g" random*.job
	sed -i "s/parallel/serial/g" random*.job
	bash qsub_random.sh;fi
	cd ../../;done;cd ../;done 
    ## UNCOMMENT THE FOLLOWING IF YOU WANT TO MONITOR THE SUBMISSION OF THE JOBS- HEALTHY FOR THE CLUSTER IF YOU WANT TO SUBMIT MORE THAN
	## 20 JOBS WITH 1 PROCESSOR
	#numjobs=$(qstat -u pchatter | wc -l)
	#if [[ $numjobs -gt 300 ]];then
	#	sleep 300
	#elif [[ $numjobs -gt 200 ]];then
	#	sleep 60
	#elif [[ $numjobs -gt 100 ]];then
	#	sleep 30
	#elif [[ $numjobs -le 50 ]];then
	#	sleep 10
	#elif [[ $numjobs -le 10 ]];then
	#	sleep 0
	#fi

	elif [[ "$prog" == "analysis" ]];then 
	for i in ${runlist[@]};do for rep in `seq 1 3`; do
 	#cd run${i}/rep${rep}/analysis
	echo `pwd`
	if [[ -d run${i}/rep${rep}/analysis/anacond_${resi} ]];then echo "cond dir exists!";
		condstatus=$(grep "NORMAL" run${i}/rep${rep}/analysis/anacond_${resi}/*.out | awk '{print $1}' )	
		if [[ $condstatus == "ABNORMAL" ]];then cd run$i/rep${rep}/analysis; 
		#qsub anacond.sh; 
		cd ../../../;fi
	elif [[ ! -d run${i}/rep${rep}/analysis/anacond_${resi} ]];then
		echo "no condir found! This happens on nodes n170 & n171 on ocracoke!!"
		cd run$i/rep${rep}/analysis;
		#qsub anacond.sh;
		cd ../../../;fi
	if [[ -d run${i}/rep${rep}/analysis/anagas_${resi} ]];then echo "gas dir exists!";
		gastatus=$(grep "NORMAL" run${i}/rep${rep}/analysis/anacond_${resi}/*.out | awk '{print $1}' )	
		if [[ $gastatus == "ABNORMAL" ]];then cd run$i/rep${rep}/analysis; 
		#qsub anagas.sh; 
		cd ../../../;fi
	elif [[ ! -d run${i}/rep${rep}/analysis/anagas_${resi} ]];then echo "gas dir not found!";
		cd run$i/rep${rep}/analysis;
		##UNCOMMENT THE FOLLWOING IF YOU WANT TO SUBMIT MULTIPLE JOBS TOGETHER 
		#numjobs=$(qstat -u pchatter | grep "$resi" | wc -l)
		#if [[ $numjobs -gt 300 ]];then
		#	sleep 300
		#elif [[ $numjobs -gt 200 ]];then
		#	sleep 60
		#elif [[ $numjobs -gt 100 ]];then
		#	sleep 30
		#elif [[ $numjobs -le 50 ]];then
		#	sleep 10
		#elif [[ $numjobs -le 10 ]];then
		#	sleep 0
		#fi
		cd ../../../;fi
	echo "=====run${i}/rep${rep}===ANALYSIS====";grep "TERMINATION" run${i}/rep${rep}/analysis/ana*/*.out ;
	done;done
	
	elif [[ $prog == "analines" ]];then
	for i in ${runlist[@]};do for rep in `seq 1 3`; do
	cnlines=$(wc -l run${i}/rep${rep}/analysis/ana*/ene* );cl=$( echo $cnlines | cut -f 1 -d" ");if [ "$cl" != "100" ];then echo check run${i}/rep${rep};fi
	gnlines=$(wc -l run${i}/rep${rep}/analysis/ana*/gasene* );gl=$( echo $gnlines | cut -f 1 -d" ");if [ "$gl" != "10584" ];then echo check run${i}/rep${rep} ;fi
	done;done
	fi
	
elif [[ "$action" == "calc" ]];then
	for i in ${runlist[@]}
	do cd run${i}
	for rep in `seq 1 3`;do 
	cd rep${rep}
	dir=`pwd`
	molwt=$(cat vars_box.str | grep molweight | awk '{print $3}')

	dens=$(cat vars_box.str | grep density | awk '{print $3}')

	temp=$(cat vars_box.str | grep " tempr " | awk '{print $3}')

	resi=$(cat vars_box.str | grep "residue " | awk '{print $3}' )

	nmol=216
	echo "processing  ${resi}/drude/t${temp}/run${i}/rep${rep}"

	echo "run${i}_rep${rep}" > results_run${i}_rep${rep}
    echo "===========run${i}/rep${rep}=============="	
	echo "volume:" >> results_run${i}_rep${rep}
	./vm.py analysis/anacond_*/xtal*dat ${nmol} >> results_run${i}_rep${rep}

	echo "Heat of vap.:" >> results_run${i}_rep${rep}
	./hval.py analysis/anagas_*/gasene* analysis/anacond_*/energy*.dat ${nmol} $temp >> results_run${i}_rep${rep}

	#echo analysis/ana_gas*/gasene* analysis/ana_cond*/energy*dat ${nmol} $temp 
	cp ${workdir}/enma.py .
	./enma.py analysis/anacond_*/dipol* analysis/anacond_*/xtal*.dat $temp >> results_run${i}_rep${rep}

	echo "====run${i}/rep${rep}:=====" >> run${i}_rep${rep}_results
	cat results_run${i}_rep${rep} > ${workdir}/master_result_${resi}_${tempr}_run${i}_rep${rep}.dat 
	cd ../
	done
	cd ../
    done 
fi
cd ../
fi
done
cd ../../

done  2>&1 | tee progress_report.txt	
