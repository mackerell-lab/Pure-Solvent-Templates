#$ -S /bin/sh
#$ -cwd
#$ -V
#$ -j y
#$ -N g%resi%
#$ -l h_data=1200M,h_rt=168:00:00
#$ -pe mpirun1 8
#$ -R y


echo $HOSTNAME $JOB_ID `date`

charmm=/opt/mackerell/apps/charmm/parallel/c44a1-parallel

mpirun="mpirun --leave-session-attached"
ulimit -c 4


group=%group%
resi=%resi%
run=run%run%
rep=rep%rep%
tempr=%tempr%
scratch=/tmp/$USER
wrkdir=`pwd`
anagasDir=anagas_${resi}

if [ ! -d ${scratch} ] ; then mkdir ${scratch} ; fi
cd ${scratch}
echo "going to ${scratch}"
	
	echo making job_${JOB_ID}
	mkdir job_${JOB_ID}
	cd job_${JOB_ID}
	
	mkdir -p $anagasDir
	echo "going to $anagasDir.."
	cd $anagasDir
	cp $wrkdir/ana_gas.inp .
	cp $wrkdir/*gas.str .
	$mpirun $charmm vars=vars_gas consts=consts_gas -i  ana_gas.inp >  ana_gas.out 
    cd ../
	cp -r $anagasDir $wrkdir/
	cd ../
	rm -r job_${JOB_ID} 
