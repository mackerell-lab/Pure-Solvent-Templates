#!/bin/bash


### author : Payal Chatterjee
### purpose : final extraction of the vm, hvap and dielectric consts. in one file
### used with the "calc" step of the prep_reps_drude.sh file
### check carefully as the atom types will need to be changed below

echo enter resi
read resi
echo "enter scan; 1 or 2 or 3"
read scan

echo enter temperature
read tempr

echo enter paramfile
read paramfile

runlist=$(cat $paramfile  | awk -F',' 'NR>1 {print $2}') 
for i in ${runlist[@]};do 
for j in `seq 1 3`;do cat master_result_${resi}_t${tempr}_run${i}_rep${j}.dat >> results_${resi}_t${tempr}_scan${scan}.txt;done;done
#rm master*
python parse_results.py ${resi} ${tempr} ${scan}
sed -i "s/_rep/,rep/g" results_${resi}_t${tempr}_scan${scan}.csv


echo "run,rep,CQ3R4A_EP,CQ3R4A_RAD,OQ3C4A_EP,OQ3C4A_RAD" > vars_${resi}_t${tempr}_scan${scan}.csv
for i in ${runlist[@]};do 

for j in `seq 1 3`;do
cq3r3aep=$(echo -n "run${i},rep${j},"; grep "^CQ3R4A" ${resi}/drude/t${tempr}/run${i}/rep${j}/toppar_drude/toppar_all36_dgenff.str | grep -v "^!" | awk '{print $3}');
cq3r3arad=$(grep "^CQ3R4A" ${resi}/drude/t${tempr}/run${i}/rep${j}/toppar_drude/toppar_all36_dgenff.str | grep -v "^!" | awk '{print $4}');
oq3c3aep=$(grep "^OQ3C4A" ${resi}/drude/t${tempr}/run${i}/rep${j}/toppar_drude/toppar_all36_dgenff.str | grep -v "^!" | awk '{print $3}');
oq3c3arad=$(grep "^OQ3C4A" ${resi}/drude/t${tempr}/run${i}/rep${j}/toppar_drude/toppar_all36_dgenff.str | grep -v "^!" | awk '{print $4}');
echo "${cq3r3aep},${cq3r3arad}, ${oq3c3aep}, ${oq3c3arad}" >> vars_${resi}_t${tempr}_scan${scan}.csv


done;done
sed -i "s/$//g" vars_${resi}_t${tempr}_scan${scan}.csv

cat results_${resi}_t${tempr}_scan${scan}.csv| cut -f 3-5 -d',' > ${resi}_t${tempr}_scan${scan}_vol_hvap.txt
paste -d "," vars_${resi}_t${tempr}_scan${scan}.csv ${resi}_t${tempr}_scan${scan}_vol_hvap.txt > results_${resi}_t${tempr}_scan${scan}.csv
#fi

