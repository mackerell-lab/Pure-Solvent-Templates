#$ -S /bin/sh
#$ -cwd
#$ -V
#$ -o s1-R%run%R%rep%%resi%
#$ -j y
#$ -N s1-R%run%R%rep%%resi%
#$ -l h_data=600M,h_rt=96:00:00
#$ -pe mpirun1 8
#$ -R y

ulimit -c 8
scratch=/tmp/pchatter
wrkdir=`pwd`
if [ ! -d $scratch ] ; then mkdir $scratch; fi
cs $scratch
#Path to most appropriate mpirun is set system-wide by Ron,
#but we still need --no-daemonize
mpirun="mpirun --leave-session-attached"
#We typically do want full control over which CHARMM versions we're using
charm_parallel=/opt/mackerell/apps/charmm/parallel/charmm-parallel

echo making job_${JOB_ID}
mkdir job_${JOB_ID}
cd job_${JOB_ID}

mkdir step1-boxequil
echo "entering step1-boxequil"
##cp -p $wrkdir/step0-initbox/$resi.box.1.res step1-boxequil/
cp -r $wrkdir/step0-initbox .
cp -p $wrkdir/vars_box.str .
cp -p $wrkdir/consts_box.str .
cp -p $wrkdir/step1-boxequil.inp .
$mpirun $charm_parallel vars=vars_box consts=consts_box -i step1-boxequil.inp -o step1-boxequil.out
cp -r step1-boxequil $wrkdir/
cp step1-boxequil.out $wrkdir/
cd ../
rm -r job_${JOB_ID}

