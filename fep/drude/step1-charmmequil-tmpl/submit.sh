#$ -S /bin/sh 
#$ -cwd
#$ -V
#$ -o jobout
#$ -j y
#$ -N fep%resi% 
#$ -l h_data=500M,h_rt=960:00:00
#$ -pe mpirun1 12
#$ -R y
echo $HOSTNAME $JOB_ID `date`
ulimit -c 4

charmm=/opt/mackerell/apps/charmm/parallel/c44a1-parallel
mpirun="mpirun --leave-session-attached"
cwd=`pwd`

$mpirun $charmm -i step1-charmmequil.inp -o step1-charmmequil.out 
