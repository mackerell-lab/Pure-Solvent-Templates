#!/bin/bash

cwd=`pwd`
echo enter resilistfile
read resilistfile
echo enter group
read group
echo enter paramfile
read paramfile

#/home/pchatter/miniconda3/envs/essentials/bin/python create_parmat.py toppar_all36_dgenff.str $paramfile
resilist=$(cat $resilistfile)
runlist=$(cat $paramfile | awk -F',' 'NR>1{ print $2}' )
for res in ${resilist[@]};do
if [[ ! -d ${res} ]];then mkdir ${res};fi
cd ${res};
for set in ${runlist[@]};do
	if [[ ! -d run${set} ]];then mkdir run${set};fi
    #mkdir -p run${set}/
	for rep in `seq 1 3`;do
	cp -r ${cwd}/fep_template run${set}/rep${rep}
	cp -r step1-charmmequil/parameters run${set}/rep${rep}/water/toppar
	cp -r step1-charmmequil/parameters run${set}/rep${rep}/vac/toppar
	cp -r step1-charmmequil/parameters run${set}/rep${rep}/LRC/toppar
	echo "$res : `pwd`"
	cp -r /home/pchatter/vdw/${group}/fep/pardir_scanrg/toppar_all36_dgenff.str-${set} run${set}/rep${rep}/water/toppar/toppar_all36_dgenff.str
    cp -r ${cwd}/${res}/step1-*/parameters/${res}*.str run${set}/rep${rep}/water/toppar/
    boxsize=$(grep LATTICE step1-charmmequil/output/${res}.1.crd | awk '{print $4}')
	boxprec=$(printf "%.2f\n" $boxsize)

	cp step1-charmmequil/output/${res}.1.crd  ${res}_wbox.crd 
	cp step1-charmmequil/output/${res}.1.crd  run${set}/rep${rep}/water/${res}_wbox.crd 
	
	head -n 3 ${res}_wbox.crd > ${res}_gas.crd 
    numatoms=$(grep SOLU ${res}_wbox.crd | wc -l )
    echo "      $numatoms  EXT" >> ${res}_gas.crd
    grep SOLU ${res}_wbox.crd >> ${res}_gas.crd
	cp ${res}_gas.crd run${set}/rep${rep}/vac/


    cp -rfp run${set}/rep${rep}/water/${res}_wbox.crd run${set}/rep${rep}/LRC/
	
    sed -i -e "s~XXX~${res}~g" run${set}/rep${rep}/vac/parset.str
    sed -i -e "s~XXX~${res}~g" run${set}/rep${rep}/water/parset.str
    sed -i -e "s~%resi%~${res}~g" run${set}/rep${rep}/vac/parset.str
    sed -i -e "s~%resi%~${res}~g" run${set}/rep${rep}/water/fep.run
    sed -i -e "s~%resi%~${res}~g" run${set}/rep${rep}/vac/fep.run
    sed -i -e "s~%rseed%~$RANDOM~g" run${set}/rep${rep}/vac/fep.run
    sed -i -e "s~%run%~${set}~g" run${set}/rep${rep}/water/fep.run
    sed -i -e "s~%run%~${set}~g" run${set}/rep${rep}/vac/fep.run
    sed -i -e "s~XXX~${res}~g" run${set}/rep${rep}/LRC/submit_lrc
    sed -i -e "s~%rseed%~67455667~g" run${set}/rep${rep}/LRC/submit_lrc
    sed -i -e "s~%run%~${set}~g" run${set}/rep${rep}/LRC/submit_lrc
	sed -i "s/%boxsize%/$boxprec/g" run${set}/rep${rep}/vac/parset.str
	sed -i "s/%boxsize%/$boxprec/g" run${set}/rep${rep}/water/parset.str
	sed -i "s/%boxsize%/$boxprec/g" run${set}/rep${rep}/LRC/*.inp
    sed -i -e "s~%resi%~${res}~g" run${set}/rep${rep}/LRC/*.inp
	done
done
cd ../
done
