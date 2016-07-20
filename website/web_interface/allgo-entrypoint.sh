#!/bin/bash
######################################################################################
#
# Description:
#    This script is entry point for the GATB pipeline deployed on the SaaS Allgo platform.
#
# Usage:
#
#    Default mode: launch the GATB pipeline
#      ./allgo-entrypoint.sh 
#    or (equivalent)
#      ./allgo-entrypoint.sh -t pipeline
#
#    Post-processing modules:
#      ./allgo-entrypoint.sh -t download -c 1,2,5 -u http://www.some.address.fr/a/b/c/assembly.fasta
#      ./allgo-entrypoint.sh -t download -c 1,2 -u https://allgo.inria.fr/datastore/147/122/4499/assembly_NOT_YET_sorted_by_size.fasta
######################################################################################

set -xv

usage() { echo "Usage: $0 [-t <pipeline|download>] [-u <file_url>] [-c <contigs_list>]" 1>&2; exit 1; }

#... Parse command line arguments
while getopts ":ht:u:c:" opt; do
    case "${opt}" in
        h)
            usage
            ;;
        t)
            run_type=${OPTARG}
            ;;
        u)
            file_url=${OPTARG}
            ;;            
        c)
            contigs_list=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

echo "run_type = ${run_type}"
echo "file_url = ${file_url}"
echo "contigs_list = ${contigs_list}"

#... Define some paths
PATH="/home/gatb-pipeline/bwa-0.7.10/:.:$PATH"
GIT_SRC_DIR=/home/gatb-pipeline/git-gatb-pipeline
DATADIR=`pwd`    # we're in /tmp

#... Prepare a directory for the run
RUNDIR=/rundir
mkdir $RUNDIR
cd $RUNDIR

######################################################################################
# This function runs the full GATB pipeline
run_pipeline() {
######################################################################################

  #... Define gatb-pipeline input files
  INPUT_FILES=$DATADIR/*.fa*

  #... Launch the gatb-pipeline main python script
  $GIT_SRC_DIR/gatb --12 $INPUT_FILES > $DATADIR/output.log

  #... Call the 1rst post-processing module
  $GIT_SRC_DIR/website/modules/module.py > $DATADIR/stats.json

  #... Expose the expected output data, this makes the resulting assembly file downloadable
  #    (other files produced by the pipeline remain hiddden) 
  cp -H assembly.fasta $DATADIR/assembly_NOT_YET_sorted_by_size.fasta
  #cp -H assembly_sorted_by_size.fasta $DATADIR/
}


######################################################################################
# This function extracts a subset of contigs from the GATB pipeline assembly file
run_module_download() {
######################################################################################
  
  echo "Running run_module_download ..."

  [ -z "$file_url" ] && usage
  [ -z "$contigs_list" ] && { echo "No contigs_list specified, NO contigs will be downloaded ..."; }

  wget $file_url
   
  #... Call the "download" post-processing module
  #    example: python download.py "https://allgo.inria.fr/datastore/35/122/4368/assembly.fasta" [2,3,1]
  $GIT_SRC_DIR/website/modules/download.py $file_url [$contigs_list] > extracted_contigs.fasta 

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
	pipeline|*)
	run_pipeline
	;;
esac
