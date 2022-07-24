#$ -S /bin/sh 
#$ -cwd
#$ -V
#$ -o %resi%R%run%R%rep%
#$ -j y
#$ -N %resi%R%run%R%rep%
#$ -l h_data=1000M,h_rt=960:00:00
#$ -pe mpirun1 16
#$ -R y
echo $HOSTNAME $JOB_ID `date`
ulimit -c 4
NAMDDIR=/opt/mackerell/apps/namd/latest

cwd=`pwd`
inputf=${cwd}/namd-equil
cd /tmp
mkdir -p $USER
cd $USER
mkdir job_${JOB_ID}
cd job_${JOB_ID}

rsync -auz ${cwd}/* ./


##leaving out one thread gives best speed
npc=$(($NSLOTS-1))
$NAMDDIR/charmrun $NAMDDIR/namd2 +p$npc +commthread +setcpuaffinity namd-equil.conf > namd-equil.out
rsync -auz ./* ${cwd}/
cd ..
rm -rf job_${JOB_ID}
cd ${cwd}
