#$ -S /bin/sh
#$ -cwd
#$ -V
#$ -j y
#$ -N C%resi%
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
scratchdir=/tmp/$USER
wrkdir=`pwd`
anaconDir=anacond_${resi}

if [ ! -d "${scratchdir}" ]; then echo "${scratchdir} directory did not exist, making one now.." ; mkdir ${scratchdir} ; echo "going to ${scratchdir}.." ; fi
echo "going to ${scratchdir}"	
cd ${scratchdir}

	echo making job_${JOB_ID}
	mkdir job_${JOB_ID}
	cd job_${JOB_ID}
	mkdir -p $anaconDir
	echo "going to $anaconDir .."
	cd $anaconDir
	cp $wrkdir/ana_cond.inp .
	cp $wrkdir/*_cond.str .

	$mpirun $charmm vars=vars_cond consts=consts_cond -i  ana_cond.inp >  ana_cond.out 


	cd ../
	echo "finished jobs, returning to `pwd`"
	cp -r $anaconDir $wrkdir
	cd ../
	rm -r job_${JOB_ID} 
