#!/bin/bash
#==============================================================================
#                    G A T B    P I P E L I N E
#==============================================================================
#
# History
#   2013-11-18: Change the quast command (contigs were evaluated, instead of scaffolds)
#
#==============================================================================
#
#------------------------------------------------------------------------------
# Job parameters
#------------------------------------------------------------------------------
#OAR -n gatb-p2
#OAR -l {cluster='bermuda'}/nodes=1,walltime=20:00:00
#OAR -O /temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/p2/outjobs/run.%jobid%.out
#OAR -E /temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/p2/outjobs/run.%jobid%.out

# we use IGRIDA the following IGRIDA clusters (see http://igrida.gforge.inria.fr/practices.html)
#	bermuda : 2 x 4 cores Gulftown		Intel(R) Xeon(R) CPU E5640 @ 2.67GHz		48GB


# TODOs
#   use *local* disk for the run (instead of the NFS dir. /temp_dd/...)
#	make this script more generic (currently only for cdeltel)
#	check the compilation options (O3, openmp, sse, etc.)
#	add md5sum check after transfering the data
#	synthetize results, send report


set -xv


PIP=p2   # pipeline name

source /udd/cdeltel/bioinfo/anr-gatb/gatb-pipeline/git-gatb-pipeline/gatb-pipeline-common.sh

EXT_print_job_informations

EXT_send_starting_mail

EXT_define_paths


#------------------------------------------------------------------------------
# Prepare the data
#------------------------------------------------------------------------------
#rsync -uv genocluster2:$DATA_GENOUEST/*fastq $DATA_IGRIDA/

#for Quast validation
#rsync -uv genocluster2:/omaha-beach/Assemblathon1/speciesA.diploid.fa $DATA_IGRIDA/

#------------------------------------------------------------------------------
# Download the code
#------------------------------------------------------------------------------

mkdir -p $PIPELINE
cd $PIPELINE/
pwd

EXT_download_source_code

EXT_print_versioning_informations


#------------------------------------------------------------------------------
# Compile the codes
#------------------------------------------------------------------------------
cd $PIPELINE/git-gatb-pipeline/
ln -sf ../specialk        kmergenie
#ln -sf ../superscaffolder superscaffolder
ln -sf ../debloom         minia

make
MAKE_EXIT_CODE=$?

#------------------------------------------------------------------------------
# Default simple test
#------------------------------------------------------------------------------
#make test

#------------------------------------------------------------------------------
# Assemblathon-1 benchmark
#------------------------------------------------------------------------------
#FASTQ_LIST=`ls $DATA_IGRIDA/*fastq`
FASTQ_LIST=`ls $DATA_IGRIDA/*fastq*`     # gzip
 
echo "FASTQ list : $FASTQ_LIST"
echo "Check compatibility with the command below:"

mkdir $WORKDIR/run
cd $WORKDIR/run

date
START_TIME=`date +"%s"`

#time ls xxx

time $MEMUSED $GATB_SCRIPT \
	-p $DATA_IGRIDA/frag_1.fastq.gz 			$DATA_IGRIDA/frag_2.fastq.gz  \
	-p $DATA_IGRIDA/longjump_1.fastq.gz 		$DATA_IGRIDA/longjump_2.fastq.gz \
	-p $DATA_IGRIDA/shortjump_1.fastq.gz  		$DATA_IGRIDA/shortjump_2.fastq.gz

CMD_EXIT_CODE=$?

END_TIME=`date +"%s"`

(( DURATION_TIME = END_TIME - START_TIME ))

date

EXT_non_regression_update_logbook


#------------------------------------------------------------------------------
# Job summary
#------------------------------------------------------------------------------
 
EXT_send_ending_mail


#------------------------------------------------------------------------------
# Synthetize results
#------------------------------------------------------------------------------

# Validation of the results

outfile=assembly.sspace.final.scaffolds.fasta
$QUAST_CMD $outfile -R $DATA_IGRIDA/genome.fasta --scaffolds --min-contig 100

# Non regression tests

EXT_non_regression_execution_time  # todo

EXT_non_regression_quast

EXT_non_regression_plot

#------------------------------------------------------------------------------
# Upload run reports to Genouest
#------------------------------------------------------------------------------


EXT_transfer_reports_to_genouest

