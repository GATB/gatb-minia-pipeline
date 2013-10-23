#!/bin/bash
#------------------------------------------------------------------------------
# Job parameters
#------------------------------------------------------------------------------
#OAR -n gatb-pipeline
##OAR -l {cluster='bermuda'}/nodes=1,walltime=00:10:00
#OAR -l {cluster='bermuda'}/nodes=1,walltime=15:00:00
#OAR -O /temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/outjobs/run.%jobid%.out
#OAR -E /temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/outjobs/run.%jobid%.out
##OAR --notify "mail: charles.deltel@inria.fr"

# we use IGRIDA the following IGRIDA clusters (see http://igrida.gforge.inria.fr/practices.html)
#	bermuda : 2 x 4 cores Gulftown		Intel(R) Xeon(R) CPU E5640 @ 2.67GHz		48GB


# TODOs
#       use *local* disk for the run (instead of the NFS dir. /temp_dd/...)
#	make this script more generic (currently only for cdeltel)
#	check the compilation options (O3, openmp, sse, etc.)
#	add md5sum check after transfering the data
#	synthetize results, send report

set -xv

MAIL_REPORT=charles.deltel@inria.fr

#------------------------------------------------------------------------------
# Job infos
#------------------------------------------------------------------------------
echo "hostname        : " `hostname`
echo "OAR_JOB_NAME    : $OAR_JOB_NAME"
echo "OAR_JOB_ID      : $OAR_JOB_ID"
echo "OAR_ARRAY_ID    : $OAR_ARRAY_ID"
echo "OAR_ARRAY_INDEX : $OAR_ARRAY_INDEX"

SUBJECT="[gatb-p1]-job$OAR_JOB_ID-starts"
ssh igrida-oar-frontend mail $MAIL_REPORT -s "$SUBJECT" << EOF
OAR_JOB_ID: $OAR_JOB_ID - hostname: `hostname`
EOF

#------------------------------------------------------------------------------
# Host infos
#------------------------------------------------------------------------------
lstopo --of txt

#------------------------------------------------------------------------------
# Data paths
#------------------------------------------------------------------------------
DATA_GENOUEST=/omaha-beach/Assemblathon1/data/
DATA_IGRIDA=/temp_dd/igrida-fs1/cdeltel/bioinfo/Assemblathon1/data/

#------------------------------------------------------------------------------
# Define where the run will take place
#------------------------------------------------------------------------------
NOW=$(date +"%Y-%m-%d-%H:%M:%S")

WORKDIR=/temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/$NOW
#WORKDIR=/temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/2013-07-29-17:50:29
PIPELINE=$WORKDIR/gatb-pipeline
GATB_SCRIPT=$PIPELINE/git-gatb-pipeline/gatb
MEMUSED=$PIPELINE/git-gatb-pipeline/tools/memused
mkdir -p $PIPELINE

#------------------------------------------------------------------------------
# Prepare the data
#------------------------------------------------------------------------------
rsync -uv genocluster2:$DATA_GENOUEST/*fastq $DATA_IGRIDA/

#------------------------------------------------------------------------------
# Download the code
#------------------------------------------------------------------------------
cd $PIPELINE/
pwd

git clone git+ssh://cdeltel@scm.gforge.inria.fr//gitroot/gatb-pipeline/gatb-pipeline.git git-gatb-pipeline
svn co svn+ssh://scm.gforge.inria.fr/svnroot/projetssymbiose/superscaffolder             superscaffolder
svn co svn+ssh://scm.gforge.inria.fr/svnroot/projetssymbiose/minia/trunk                 debloom
svn co svn+ssh://scm.gforge.inria.fr/svnroot/projetssymbiose/specialk                    specialk

#------------------------------------------------------------------------------
# Code versioning informations
#------------------------------------------------------------------------------
INFOS_GATB_PIPELINE=$PIPELINE/git-gatb-infos.txt
INFOS_SUPERSCAFFOLDER=$PIPELINE/svn-superscaffolder-infos.txt
INFOS_DEBLOOM=$PIPELINE/svn-debloom-infos.txt
INFOS_SPECIALK=$PIPELINE/svn-specialk-infos.txt

#..............................................................................
cd $PIPELINE/git-gatb-pipeline
git log --max-count=1 > $INFOS_GATB_PIPELINE
cat $INFOS_GATB_PIPELINE
#..............................................................................
cd $PIPELINE/superscaffolder
svn info > $INFOS_SUPERSCAFFOLDER
svn log --limit 10 >> $INFOS_SUPERSCAFFOLDER
cat $INFOS_SUPERSCAFFOLDER
#..............................................................................
cd $PIPELINE/specialk
svn info > $INFOS_SPECIALK
svn log --limit 10 >> $INFOS_SPECIALK
cat $INFOS_SPECIALK
#..............................................................................
cd $PIPELINE/debloom
svn info > $INFOS_DEBLOOM
svn log --limit 10 >> $INFOS_DEBLOOM
cat $INFOS_DEBLOOM
#..............................................................................

#------------------------------------------------------------------------------
# Compile the codes
#------------------------------------------------------------------------------
cd $PIPELINE/git-gatb-pipeline/
#ln -sf ../specialk        kmergenie
#ln -sf ../superscaffolder superscaffolder
ln -sf ../debloom         minia

make

#------------------------------------------------------------------------------
# Default simple test
#------------------------------------------------------------------------------
make test

#------------------------------------------------------------------------------
# Assemblathon-1 benchmark
#------------------------------------------------------------------------------
FASTQ_LIST=`ls $DATA_IGRIDA/*fastq`
echo "FASTQ list : $FASTQ_LIST"
echo "Check compatibility with the command below:"

mkdir $WORKDIR/run
cd $WORKDIR/run
chmod a+x $MEMUSED

date
START_TIME=`date +"%s"`
time $MEMUSED $GATB_SCRIPT \
    -p $DATA_IGRIDA/speciesA_200i_40x.1.fastq       $DATA_IGRIDA/speciesA_200i_40x.2.fastq \
    -p $DATA_IGRIDA/speciesA_300i_40x.1.fastq       $DATA_IGRIDA/speciesA_300i_40x.2.fastq \
    -p $DATA_IGRIDA/speciesA_3000i_20x_r3.1.fastq   $DATA_IGRIDA/speciesA_3000i_20x_r3.2.fastq \
    -p $DATA_IGRIDA/speciesA_10000i_20x_r3.1.fastq  $DATA_IGRIDA/speciesA_10000i_20x_r3.2.fastq
END_TIME=`date +"%s"`

(( DURATION_TIME = END_TIME - START_TIME ))

date

#------------------------------------------------------------------------------
# Job summary
#------------------------------------------------------------------------------

duration()
{
 local dt=${1}
 ((h=dt/3600))
 ((m=dt%3600/60))
 ((s=dt%60))
 printf "%03dh:%02dm:%0ds\n" $h $m $s
}

echo "Assemblathon-1 benchmark:"
echo "OAR_JOB_ID: $OAR_JOB_ID - hostname: `hostname` - START_TIME: $START_TIME - END_TIME: $END_TIME - DURATION: `duration $DURATION_TIME`"

SUBJECT="[gatb-benchmark]-job$OAR_JOB_ID-ends-`duration $DURATION_TIME`"
ssh igrida-oar-frontend mail $MAIL_REPORT -s "$SUBJECT" << EOF
echo "OAR_JOB_ID: $OAR_JOB_ID - hostname: `hostname` - START_TIME: $START_TIME - END_TIME: $END_TIME - DURATION: `duration $DURATION_TIME`"
EOF

#------------------------------------------------------------------------------
# Synthetize results
#------------------------------------------------------------------------------

# Validation of the results
# Non regression test (performances)






