#$ -S /bin/sh
#$ -cwd
#$ -V
#$ -j y
#$ -N s0-%resi%
#$ -l h_data=600M,h_rt=168:00:00
#$ -pe mpirun1 12
#$ -R y

charmm=/opt/mackerell/apps/charmm/parallel/charmm-parallel




mpirun="mpirun --leave-session-attached"
ulimit -c 8

$mpirun $charmm vars=vars_box consts=consts_box -i  step0-initbox.inp > step0-initbox.out 
