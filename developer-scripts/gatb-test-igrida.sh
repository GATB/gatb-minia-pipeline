#!/bin/bash
# short test (~ 10 minutes)
#OAR -n gatb-test
#OAR -p dedicated='none'
#OAR -l {cluster='bermuda'}/nodes=1,walltime=00:15:00
#OAR -O /temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/test/outjobs/run.%jobid%.out
#OAR -E /temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/test/outjobs/run.%jobid%.out

# =================== job informations =========================================
echo "hostname        : " `hostname`
echo "TODAY           : $TODAY"
echo "OAR_JOB_NAME    : $OAR_JOB_NAME"
echo "OAR_JOB_ID      : $OAR_JOB_ID"
echo "OAR_ARRAY_ID    : $OAR_ARRAY_ID"
echo "OAR_ARRAY_INDEX : $OAR_ARRAY_INDEX"

RUNDIR=/temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/test/run

[ -d $RUNDIR ] || { mkdir $RUNDIR; } && { rm -rf $RUNDIR/*; }


GITDIR=~/bioinfo/anr-gatb/gatb-pipeline/git-gatb-pipeline/

set -xv

cd $GITDIR

# BESST
git submodule init
git submodule update
git submodule status

# superscaffolder => now we use BESST instead
# cd ../superscaffolder 
# svn update

# minia => currently use the pre-compiled binary file (see minia/minia*)
# ln -sf ../debloom   minia
# cd ../debloom/
# svn update

# bwa
PATH="/udd/cdeltel/bioinfo/bwa-0.7.10/:.:$PATH"

# ================= default very short test ====================================
cd $GITDIR/test
../gatb --12 small_test_reads.fa.gz

# ================= short pipeline test (p3) ===================================
DATA_NAME=Staphylococcus_aureus/Data/original   # this is pipeline p3
DATA_IGRIDA=/temp_dd/igrida-fs1/cdeltel/bioinfo/${DATA_NAME}/

FASTQ_LIST=`ls $DATA_IGRIDA/*fastq*`     # gzip
 
echo "FASTQ list : $FASTQ_LIST"
echo "(check compatibility with the command below)"

cd $RUNDIR

MEMUSED=$GITDIR/tools/memused
GATB_SCRIPT=$GITDIR/gatb

time $MEMUSED $GATB_SCRIPT \
	-1 $DATA_IGRIDA/frag_1.fastq 			-2 $DATA_IGRIDA/frag_2.fastq  \
	-1 $DATA_IGRIDA/shortjump_1.fastq  		-2 $DATA_IGRIDA/shortjump_2.fastq

