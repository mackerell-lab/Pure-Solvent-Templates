#$ -S /bin/sh
#$ -cwd
#$ -V
#$ -j y
#$ -N s1-%resi%
#$ -l h_data=1200M,h_rt=168:00:00
#$ -pe mpirun1 16
#$ -R y

charmm=/opt/mackerell/apps/charmm/parallel/c44a1-parallel
mpirun="mpirun --leave-session-attached"
ulimit -c 4
cwd=`pwd`


cd /tmp
mkdir -p $USER
cd $USER
mkdir job_${JOB_ID}
cd job_${JOB_ID}

rsync -auz ${cwd}/* ./

$mpirun $charmm vars=vars_box consts=consts_box -i step1-boxequil.inp -o step1-boxequil.out
wait
cp -r step1-boxequil ${cwd}/
cp step1-boxequil.out ${cwd}/
cd ../
rm -rf job_${JOB_ID}
cd ${cwd}
