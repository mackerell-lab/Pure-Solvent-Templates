#!/bin/bash


### author : Payal Chatterjee, June 2019

echo "======================================================================="
echo "This script prepares the inputs and jobsubmission"
echo "scripts for running FEP with CHARMM"
echo "The process has the following 4 steps:"
echo "step0: Using Packmol: Setting up a waterbox of boxsize 20X20X20 cu A"
echo "step1: Using CHARMM : Creating a psf file for the residue and equilibrate"
echo "After running step0 and Step1, prepare runs for different LJ params and run HFE with Deng & Roux's protocol of CHARMM (J. Phys. Chem. B 2009, 113, 8, 2234–2246)"
echo "========================================================================"

templDir=`pwd`
echo enter group name
read group
echo enter resilist file
read reslstfile
resilist=$(cat $reslstfile)
temp=298
boxsize=20.0
echo enter step, e.g. 01,2,3
read step
for resi in ${resilist[@]};do
workDir="/home/pchatter/vdw/$group/fep/${resi}"



if [ $step == '01' ];then
	echo "step is step${step}"
	#echo enter path to parametrization dir of this residue
	#read optDir
	optDir=$workDir/
	mkdir -p $workDir/step0-packmol
	cp $templDir/step0-packmol-tmpl/step0-run_packmol.sh $workDir/step0-packmol
	sed -i "s/%resi%/$resi/g" $workDir/step0-packmol/step0-run_packmol.sh
	sed -e "s/%resi%/$resi/g" $templDir/step0-packmol-tmpl/step0-gen_wbox.tmpl > $workDir/step0-packmol/step0-gen_${resi}_wbox.inp
	#sed -i "s/%group%/$group/g" $workDir/step0-packmol/step0.1-equil_${resi}_wbox.inp
	if [[ ! -d "$workDir/step0-packmol/output" ]];then mkdir $workDir/step0-packmol/output;fi
	echo "your input file has been created now..."
	echo "making sure that you have the required inputs..."
	ls $workDir/step0-packmol
	#echo "do you want to create an 'inputs' directory? within step0-packmol?y/n" 
	#read response
	#if [ $response == 'y' ];then
		echo "creating the 'inputs' directory, within step0-packmol?y/n" 
		mkdir -p $workDir/step0-packmol/inputs
		cp $templDir/step0-packmol-tmpl/inputs/water.drude.pdb $workDir/step0-packmol/inputs
	#elif [ $response == 'n' ];then
	#	echo "okay..quitting now!"
	#fi
	cp $optDir/${resi}_min.pdb $workDir/step0-packmol/inputs 
	echo "======= CHECK THE FOLLOWING REQUIREMENTS BEFORE STARTING ========="
	echo "1. Do you have ${resi}.pdb in $workDir/step0-packmol/inputs ?"
	echo "2. Do you have water.drude.pdb in $workDir/step0-packmol/inputs ?"
	echo "3. Checkif the $resi_min.pdb looks good!"
	echo "4. execute step0-run_packmol.sh to run packmol & convert the pdb to crd"

#elif [ $step == '1' ];then
#	echo "step is step${step}"
	mkdir -p $workDir/step1-charmmequil
	#echo enter path to parametrization dir of this residue
	#read optDir
	
	mkdir -p $workDir/step1-charmmequil/parameters
	#cp $optDir/all_$group.str $workDir/step1-charmmequil/parameters/ 
	cp $optDir/$resi.str $workDir/step1-charmmequil/parameters/ 
	cp -r $templDir/parameters/toppar* $workDir/step1-charmmequil/parameters
	sed -e "s/%resi%/${resi}/g" $templDir/step1-charmmequil-tmpl/step1-charmmequil.tmpl > $workDir/step1-charmmequil/step1-charmmequil.inp
	sed -e "s/%resi%/${resi}/g" $templDir/step1-charmmequil-tmpl/submit.sh > $workDir/step1-charmmequil/submit.sh
	sed -i "s/%group%/$group/g" $workDir/step1-charmmequil/step1-charmmequil.inp
	sed -i "s/%temp%/${temp}/g" $workDir/step1-charmmequil/step1-charmmequil.inp
	sed -i "s/%rseed%/$RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM/g" $workDir/step1-charmmequil/step1-charmmequil.inp

	
fi
done	


