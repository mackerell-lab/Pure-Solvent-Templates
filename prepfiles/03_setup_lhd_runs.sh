#!/bin/bash
# author : Payal Chatterjee, June 2021

# purpose : setup the systems from the templates and change the LJ parameters in multiple files
# requirements : 
## 1. Assumptions:
### a. that the `pwd` has directories ${resi}/drude/${tempr}/templ such that ${tempr} could be one or many (temperatures - epxperimental)
### b. since ${tempr} is name of a folder I use rounded off values - ex. 298 instead of 298.15 K . use this consistently also in vars_*.str file while preparing the templates
### c. that the there exists a toppar_all36_dgenff.str file with the replacable LJ parameters of the atom types under optimization.
#### example: HQ1C1B   0.00  %EPSI0%     %RAD0% ! ALKYNES LHD
#### where %EPSI0% and %RAD0% will be replaced by create_parmat.py file.

### d. Check the create_parmat.py file to change your replacable variables. 




echo enter group
read group

echo enter scan: 1 or 2 or 3
read scan
echo enter paramfile
read paramfile

python create_parmat.py toppar_all36_dgenff.str $paramfile 
mkdir pardir_scan${scan}
mv toppar_all36_dgenff.str-* -t pardir_scan${scan}/
pardir="/home/pchatter/vdw/${group}/pardir_scan${scan}/"
resilist=$(cat $1)
cwd=`pwd`

for resi in ${resilist[@]};do
cd ${resi}/drude
for tempr in t[0-9]*;do
if [[ $tempr != 100 ]];then
cd $tempr

cp  ${cwd}/$paramfile .

templateDir=`pwd`
echo ${templateDir}

runlist=$(cat $paramfile  | awk -F',' 'NR>1 {print $2}') 



for run in ${runlist[@]};do 
cp -r templ run$run
workdir=$templateDir/run$run


done

for run in ${runlist[@]};do
	cd run$run;
	mkdir reptempl
	mv * reptempl;

	for rep in `seq 1 3`;do 
		cp -r reptempl rep${rep};
		cd rep$rep
		rm toppar_drude/toppar_all36_dgenff.str
		
		cp  ${cwd}/updated_strs/${resi}.str ${resi}.str
		cp  ${cwd}/updated_strs/${resi}.str toppar_drude/${resi}.str
		cp $pardir/toppar_all36_dgenff.str-${run} toppar_drude/toppar_all36_dgenff.str
		
		### the following pieces could be used when iterating through multiple rounds of LHD scans; such that best of one scan is starting point of the next
        ### in such a case charmm step could be skipped and the previously equil box in CHARMM could be used for a longer production run with NAMD
		#cp -r $templateDir/bestrun_scan2/rep${rep}/step1-boxequil .
		#cp $templateDir/bestrun_scan2/rep${rep}/toppar_drude/toppar_drude_master.str toppar_drude/
		#cp $templateDir/bestrun_scan2/rep${rep}/toppar_drude/${resi}.str toppar_drude/
		#cp -r $templateDir/bestrun_scan2/rep${rep}/${resi}_box_equil.pdb .
		#cp
		sed -i "s/%run%/$run/g" job_step1.sh
		sed -i "s/%run%/$run/g" vars_box.str
		sed -i "s/%run%/$run/g" namd-equil.conf
		sed -i "s/%run%/$run/g" job_namd.sh 
		sed -i "s/%run%/$run/g" vars_box.str 
		sed -i "s/%run%/$run/g" step2-monodata/random*.job 
		sed -i "s/%run%/$run/g" step2-monodata/vars_mono.str
		sed -i "s/%run%/$run/g" analysis/*.str
		sed -i "s/%run%/$run/g" analysis/*.sh
		sed -i "s/%rep%/$rep/g" job_step1.sh
		sed -i "s/%rep%/$rep/g" vars_box.str
		sed -i "s/%rep%/${rep}/g" job_namd.sh
		sed -i "s/%rep%/${rep}/g" namd-equil.conf
		sed -i "s/%namdseed%/${RANDOM}/g" namd-equil.conf
		sed -i "s/%rep%/${rep}/g" step2-monodata/random*.job
		sed -i "s/%resi%/${resi}/g" step2-monodata/random*.job
		sed -i "s/%rep%/${rep}/g" vars_*.str
		sed -i "s/%rep%/${rep}/g" analysis/vars_*.str
		sed -i "s/%rep%/${rep}/g" analysis/ana*.sh
		sed -i "s/%rep%/$rep/g" step2-monodata/vars_mono.str
		sed -i "s/%rseed%/$RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM/g" vars_box.str
		sed -i "s/%monorseed%/$RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM/g" step2-monodata/vars_mono.str
		sed -i "s/%rseed%/$RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM/g" step2-monodata/vars_mono.str

		cd ../
	done
cd ../
done 


cd ../
fi
done
cd ../../
done

