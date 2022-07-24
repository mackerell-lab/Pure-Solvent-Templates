#$ -S /bin/sh 
#$ -cwd
#$ -V
#$ -o jobout
#$ -j y
#$ -N fep%resi%
#$ -l h_data=500M,h_rt=960:00:00
#$ -l h=!(n084|n085)
#$ -pe mpirun1 12
#$ -R y
echo $HOSTNAME $JOB_ID `date`
ulimit -c 4

charmm=/opt/mackerell/apps/charmm/parallel/c44a1-parallel
mpirun="mpirun --leave-session-attached"
cwd=`pwd`
resi="%resi%"
$mpirun $charmm resi=$resi -i step1-charmmequil_add.inp > step1-charmmequil_add.out 
