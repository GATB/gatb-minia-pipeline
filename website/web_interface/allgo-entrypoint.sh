#!/bin/bash
set -xv

PATH="/home/gatb-pipeline/bwa-0.7.10/:.:$PATH"
GITDIR=/home/gatb-pipeline/git-gatb-pipeline
DATADIR=`pwd`    # we're in /tmp

#... Prepare a directory for the run
RUNDIR=/rundir
mkdir $RUNDIR
cd $RUNDIR

#... Define gatb-pipeline input files
INPUT_FILES=$DATADIR/*.fa*

#... Launch the gatb-pipeline main python script
$GITDIR/gatb --12 $INPUT_FILES > $DATADIR/output.log

#... Expose the expected output data, this makes the resulting assembly file downloadable
#    (other files produced by the pipeline remain hiddden) 
cp -H assembly.fasta $DATADIR/

#... Call the 1rst post-processing module
$GITDIR/website/modules/module.py > $DATADIR/stats.json
