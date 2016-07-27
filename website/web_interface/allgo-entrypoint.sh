#!/bin/bash
######################################################################################
#
# Description:
#    This script is entry point for the GATB pipeline deployed on the SaaS Allgo platform.
#
# Usage:
#
#    To launch the GATB pipeline
#      ./allgo-entrypoint.sh -t pipeline -1 /tmp/SRR959239_1_small_500Klines.fastq.gz -2 /tmp/SRR959239_2_small_500Klines.fastq.gz
#
#    To use a post-processing modules:
#      ./allgo-entrypoint.sh -t download http://www.some.address.fr/a/b/c/assembly.fasta  [contigs_list]
#      ./allgo-entrypoint.sh -t download https://allgo.inria.fr/datastore/147/122/5069/assembly.fasta [2,5,6,1]
######################################################################################

set -xv

exec > /tmp/entrypoint_output.log 2>&1

PARAMETERS=$*
NB_PARAMETERS=$#
run_type=$2

shift 2
PARAMETERS_LIST=$*

Usage() { echo "Usage: $0 -t <pipeline|download> gatb_parameters" 1>&2; exit 1;}

#... Define some paths
PATH="/home/gatb-pipeline/bwa-0.7.10/:.:$PATH"
GIT_SRC_DIR=/home/gatb-pipeline/git-gatb-pipeline
DATADIR=`pwd`    # we're in /tmp

ls -atlhrsF

#... Prepare a directory for the run
RUNDIR=/rundir
rm -rf $RUNDIR
mkdir $RUNDIR
cd $RUNDIR

ls -atlhrsF


######################################################################################
# This function runs the full GATB pipeline
run_pipeline() {
######################################################################################

  #... Launch the gatb-pipeline main python script
  $GIT_SRC_DIR/gatb $PARAMETERS_LIST > $DATADIR/gatb_output.log

  #... Call the 1rst post-processing module
  $GIT_SRC_DIR/website/modules/module.py > $DATADIR/stats.json

  #... Expose the expected output data, this makes the resulting assembly file downloadable
  #    (other files produced by the pipeline remain hiddden) 
  cp -H assembly.fasta $DATADIR/
}


######################################################################################
# This function extracts a subset of contigs from the GATB pipeline assembly file
run_module_download() {
######################################################################################
  
  echo "Running run_module_download ..."

  #... Call the "download" post-processing module
  #    example: python download.py "https://allgo.inria.fr/datastore/35/122/4368/assembly.fasta" [2,3,1]
  $GIT_SRC_DIR/website/modules/download.py $PARAMETERS_LIST > extracted_contigs.fasta 

  #... Expose the expected extracted contigs
  cp -H extracted_contigs.fasta $DATADIR/
}

######################################################################################
#                                    M A I N 
######################################################################################

case "$run_type" in
	download)
	run_module_download
	;;
	pipeline)
	run_pipeline
	;;
  *)
  Usage
  ;;
esac
