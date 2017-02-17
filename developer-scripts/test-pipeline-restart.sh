#!/bin/bash
#OAR -n test-pipeline-restart
#OAR -l /nodes=1,walltime=1:00:00
##OAR -p cluster='lambda'
#OAR -p host='igrida12-01.irisa.fr'
#OAR -O /temp_dd/igrida-fs1/cdeltel/bioinfo/outjobs/test-pipeline-restart.%jobid%.output
#OAR -E /temp_dd/igrida-fs1/cdeltel/bioinfo/outjobs/test-pipeline-restart.%jobid%.output
#
# Cf. redmine gatb-pipeline issue 54
#
# Example commands:
#   ./test-pipeline-restart.sh &> output.$(date +%F_%R).log
#   oarsub -S  ./test-pipeline-restart.sh
#   To check results: grep "=>" in test-pipeline-restart.%jobid%.output

echo "
-----------------------------------------------------------
   Some tests to check gatb-pipeline restartability
   either on error, or to resume minia iterations (on k)
-----------------------------------------------------------"

[ -z "$OAR_JOBID" ] && { myecho "Error, this script must be launched inside a job"; exit 1; }

init_env() {
    # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> edit me >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    export GATB_dir=/udd/cdeltel/gatb/gatb-pipeline
    export DATADIR=$GATB_dir/gatb-web-test-data
    export GATB_script=$GATB_dir/git-gatb-pipeline/gatb
    export BWA_PATH=/udd/cdeltel/bioinfo/bwa-0.7.10

    USE_CASE=1
    case $USE_CASE in
      1)
      export WORKDIR=/temp_dd/igrida-fs1/cdeltel/workdir-test-pipeline-restart-1file
      export DATA_OPTIONS="-s $DATADIR/small_test_reads.fa.gz"
      ;;
      2)
      export WORKDIR=/temp_dd/igrida-fs1/cdeltel/workdir-test-pipeline-restart-2files
      export DATA_OPTIONS="-1 $DATADIR/SRR959239_1_small_100Klines.fastq.gz -2 $DATADIR/SRR959239_2_small_100Klines.fastq.gz"
      ;;
      *)
      myecho "Error in USE_CASE"
      exit
      ;;
    esac
    myecho "Pipeline data options : $DATA_OPTIONS"

    [ -d $WORKDIR ] && { myecho "Cleaning $WORKDIR..."; rm -rf $WORKDIR; }
    export PATH="$BWA_PATH:$PATH"

    # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}

myecho () { echo "=> $*"; }

########################################################################################
# 1. Without Bloocoo (use --no-error-correction)
########################################################################################

#---------------------------------------------------------------------------------------
# 1.1 Runs without bloocoo, without restart: ref. results, repeat to check reproductibility
#---------------------------------------------------------------------------------------

without_bloocoo_reference () {
    [ -z $1 ] && { echo " Missing argument"; exit; }

    #-- minia single-threaded, no bloocoo
    myecho "without_bloocoo_reference : reference run..."
    WORKDIR_subdir=without_bloocoo_debug_mode_1
    for runId in $reproductibility_iterations; do
      TMPDIR=$WORKDIR/$WORKDIR_subdir/run-$runId
      mkdir -p $TMPDIR && cd $TMPDIR
      [ "$1" = "YES" ] && { time $GATB_script --debug 1 --no-error-correction $DATA_OPTIONS; } || { myecho "no run"; }
      eval export ASB_REF_without_bloocoo_debug_mode_1_run${runId}=$TMPDIR/assembly.fasta
    done
}

#---------------------------------------------------------------------------------------
# 1.2 Runs without bloocoo, with restart ON ERROR
#---------------------------------------------------------------------------------------
without_bloocoo_restart_on_error () {
    [ -z $1 ] && { myecho " Missing argument"; exit; }

    TMPDIR=$WORKDIR/without_bloocoo_debug_mode_1_restart_on_error/run-1
    export ASB_without_bloocoo_restart_on_error_run1=$TMPDIR/assembly.fasta

    myecho "without_bloocoo_restart_on_error"
    if [ "$1" != "YES" ]; then # only useful to recall ABS_ env. variable
      myecho "no run"

    else
      [ -d $TMPDIR ] && { myecho "Cleaning $TMPDIR..."; rm -rf $TMPDIR; }
      mkdir -p $TMPDIR && cd $TMPDIR

      #-- step 1 : emulate an error
      myecho "without_bloocoo_restart_on_error : emulate an error..."

      ############################ RUN ############################
      $GATB_script --debug 1 --no-error-correction $DATA_OPTIONS &
      #############################################################

      pid=$! && touch step1.pid$pid.started
      WATCH_FILE=assembly.list_reads.41
      while [ ! -f $WATCH_FILE ]; do sleep 2; done

      touch step1.pid$pid.killed
      killall python memused minia

      myecho "without_bloocoo_restart_on_error continue"
      sleep 5

      #-- step 2 : resume interrupted simulation (restart on error)
      myecho "without_bloocoo_restart_on_error : resume interrupted simulation (restart on error)..."

      ############################ RUN ############################
      $GATB_script --debug 1 --no-error-correction $DATA_OPTIONS --restart-from 41 &
      #############################################################

      pid=$! && touch step2.pid$pid.started
      wait $pid && touch step2.pid$pid.ended

    fi

    #-- check results
    myecho "without_bloocoo_restart_on_error : check results... "
    diff $ASB_REF_without_bloocoo_debug_mode_1_run1 $ASB_without_bloocoo_restart_on_error_run1 > /dev/null
    [ $? -eq 0 ] && { myecho "OK, same results"; } || { myecho "WARNING!! results differ..."; }
}

#---------------------------------------------------------------------------------------
# 1.2 Without bloocoo, with restart TO RESUME ITERATIONS
#---------------------------------------------------------------------------------------

without_bloocoo_restart_for_more_iterations () {
    # cutoffs: [(21, 2), (41, 2), (61, 2), (81, 2)]
    [ -z $1 ] && { myecho "Missing argument"; exit; }

    TMPDIR=$WORKDIR/without_bloocoo_debug_mode_1_restart_for_more_iterations/run-1
    export ASB_without_bloocoo_debug_mode_1_restart_for_more_iterations_run1=$TMPDIR/assembly.fasta

    myecho "without_bloocoo_restart_for_more_iterations"
    if [ "$1" != "YES" ]; then # only useful to recall ABS_ env. variable
      myecho "no run"

    else
      [ -d $TMPDIR ] && { myecho "Cleaning $TMPDIR..."; rm -rf $TMPDIR; }
      mkdir -p $TMPDIR && cd $TMPDIR

      #-- step 1 : first set of iterations (21,41,61)
      myecho "without_bloocoo_restart_for_more_iterations : start iterations..."

      ############################ RUN ############################
      $GATB_script --debug 1 --no-error-correction $DATA_OPTIONS --kmer-sizes 21,41,61&
      #############################################################

      pid=$! && touch step1.pid$pid.started
      wait $pid && touch step1.pid$pid.ended

      #-- step 2 : continue iterations (81)
      myecho "without_bloocoo_restart_for_more_iterations : resume iterations..."

      ############################ RUN ############################
      $GATB_script --debug 1 --no-error-correction $DATA_OPTIONS --restart-from 81&
      #############################################################

      pid=$! && touch step2.pid$pid.started
      wait $pid && touch step2.pid$pid.ended

    fi

    #-- check results
    myecho "without_bloocoo_restart_for_more_iterations : check results..."
    diff $ASB_REF_without_bloocoo_debug_mode_1_run1 \
         $ASB_without_bloocoo_debug_mode_1_restart_for_more_iterations_run1 > /dev/null
    [ $? -eq 0 ] && { myecho "OK, same results"; } || { myecho "WARNING!! results differ..."; }
}


########################################################################################
# 2. With Bloocoo (default)
########################################################################################

#---------------------------------------------------------------------------------------
# 2.1 Runs with bloocoo (single-threaded OR multi-threaded), without restart
#---------------------------------------------------------------------------------------
with_bloocoo_reference () {
    [ -z $1 ] && { myecho "Missing argument"; exit; }

    #-- minia single-threaded + bloocoo single-threaded
    myecho "with_bloocoo_reference : reference run-1..."
    WORKDIR_subdir=with_bloocoo_debug_mode_1
    for runId in $reproductibility_iterations; do
        TMPDIR=$WORKDIR/$WORKDIR_subdir/run-$runId
        mkdir -p $TMPDIR && cd $TMPDIR
        [ "$1" = "YES" ] && { time $GATB_script --debug 1 $DATA_OPTIONS; } || { myecho "no run"; }
        eval export ASB_REF_with_bloocoo_debug_mode_1_run${runId}=$TMPDIR/assembly.fasta
    done

    #-- minia single-threaded + bloocoo multi-threaded
    myecho "with_bloocoo_reference : reference run-2..."
    WORKDIR_subdir=with_bloocoo_debug_mode_2
    for runId in $reproductibility_iterations; do
        TMPDIR=$WORKDIR/$WORKDIR_subdir/run-$runId
        mkdir -p $TMPDIR && cd $TMPDIR
        [ "$1" = "YES" ] && { time $GATB_script --debug 2 $DATA_OPTIONS; } || { myecho "no run"; }
        eval export ASB_REF_with_bloocoo_debug_mode_2_run${runId}=$TMPDIR/assembly.fasta
    done

    #-- check results (compare run-1  and run-2), should be identical
    myecho "with_bloocoo_reference : check that run-1 and run-2 have the same results..."
    myecho "        run-1 : minia single-threaded + bloocoo single-threaded"
    myecho "        run-2 : minia single-threaded + bloocoo multi-threaded"
    diff $ASB_REF_with_bloocoo_debug_mode_1_run1 $ASB_REF_with_bloocoo_debug_mode_2_run1 > /dev/null
    [ $? -eq 0 ] && { myecho "OK, same results"; } || { myecho "WARNING!! results differ..."; }
}

#---------------------------------------------------------------------------------------
# 2.2 Runs with bloocoo (single-threaded case ONLY, to simplify), with restart ON ERROR
#---------------------------------------------------------------------------------------
with_bloocoo_restart_on_error () {
    [ -z $1 ] && { myecho "Missing argument"; exit; }

    myecho "with_bloocoo_restart_on_error"
    TMPDIR=$WORKDIR/with_bloocoo_debug_mode_1_restart_on_error/run-1
    export ASB_with_bloocoo_debug_mode_1_restart_on_error_run1=$TMPDIR/assembly.fasta

    if [ "$1" != "YES" ]; then # only useful to recall ABS_ env. variable
      myecho "no run"

    else
      [ -d $TMPDIR ] && { myecho "Cleaning $TMPDIR..."; rm -rf $TMPDIR; }
      mkdir -p $TMPDIR && cd $TMPDIR

      #-- step 1 : emulate an error
      myecho "with_bloocoo_restart_on_error : emulate an error..."

      ############################ RUN ############################
      $GATB_script --debug 1 $DATA_OPTIONS &
      #############################################################

      pid=$! && touch step1.pid$pid.started

      WATCH_FILE=assembly.list_reads.41
      while [ ! -f $WATCH_FILE ]; do sleep 2; done

      touch step1.pid$pid.killed
      killall python memused minia

      myecho "with_bloocoo_restart_on_error:  continue"
      sleep 5

      #-- step 2 : resume interrupted simulation (restart on error)
      myecho "with_bloocoo_restart_on_error : resume interrupted simulation (restart on error)..."

      ############################ RUN ############################
      $GATB_script --debug 1 $DATA_OPTIONS --restart-from 41 &
      #############################################################

      pid=$! && touch step2.pid$pid.started
      wait $pid && touch step2.pid$pid.ended

    fi

    #-- check results
    myecho "with_bloocoo_restart_on_error : check results..."
    diff $ASB_REF_with_bloocoo_debug_mode_1_run1 \
         $ASB_with_bloocoo_debug_mode_1_restart_on_error_run1 > /dev/null
    [ $? -eq 0 ] && { myecho "OK, same results"; } || { myecho "WARNING!! results differ..."; }
}

#---------------------------------------------------------------------------------------
# 2.3 Runs with bloocoo (single-threaded case ONLY), with restart to RESUME ITERATIONS
#---------------------------------------------------------------------------------------
with_bloocoo_restart_for_more_iterations () {
    # cutoffs: [(21, 2), (41, 2), (61, 2), (81, 2)]

    [ -z $1 ] && { myecho "Missing argument"; exit; }

    TMPDIR=$WORKDIR/with_bloocoo_debug_mode_1_restart_for_more_iterations/run-1
    export ASB_with_bloocoo_debug_mode_1_restart_for_more_iterations_run1=$TMPDIR/assembly.fasta

    myecho "with_bloocoo_restart_for_more_iterations"
    if [ "$1" != "YES" ]; then # only useful to recall ABS_ env. variable
      myecho "no run"

    else
      [ -d $TMPDIR ] && { myecho "Cleaning $TMPDIR..."; rm -rf $TMPDIR; }
      mkdir -p $TMPDIR && cd $TMPDIR

      #-- step 1 : first set of iterations (21,41,61)
      myecho "with_bloocoo_restart_for_more_iterations : start iterations..."

      ############################ RUN ############################
      $GATB_script --debug 1 $DATA_OPTIONS --kmer-sizes 21,41&  # not 61 because of small_test_reads.fa.gz
      #############################################################

      pid=$! && touch step1.pid$pid.started
      wait $pid && touch step1.pid$pid.ended

      #-- step 2 : continue iterations (81)
      myecho "with_bloocoo_restart_for_more_iterations : resume iterations..."

      ############################ RUN ############################
      $GATB_script --debug 1 $DATA_OPTIONS --restart-from 61&
      #############################################################

      pid=$! && touch step2.pid$pid.started
      wait $pid && touch step2.pid$pid.ended

    fi

    #-- check results
    myecho "with_bloocoo_restart_for_more_iterations : check results..."
    diff $ASB_REF_with_bloocoo_debug_mode_1_run1 \
         $ASB_with_bloocoo_debug_mode_1_restart_for_more_iterations_run1 > /dev/null
    [ $? -eq 0 ] && { myecho "OK, same results"; } || { myecho "WARNING!! results differ..."; }
}

########################################################################################
########################################################################################
##################                                                      ################
##################                      M A I N                         ################
##################                                                      ################
########################################################################################
########################################################################################

init_env

mkdir -p $WORKDIR
cd $WORKDIR

#---------------------------------------------------------------------------------------
# I. Reference runs (no restart)
#---------------------------------------------------------------------------------------

#reproductibility_iterations="1 2 3 4 5"
reproductibility_iterations="1"

#-- without bloocoo, reference simulations (repeat runs to check reproductibility)
without_bloocoo_reference     YES                 # OK

#-- with bloocoo, reference simulations (repeat runs to check reproductibility)
with_bloocoo_reference        YES                 # OK

#---------------------------------------------------------------------------------------
# II. Test restart feature
#---------------------------------------------------------------------------------------

myecho "-----------------------------"

#-- without bloocoo, 2 restart scenarios

without_bloocoo_restart_on_error             YES    # OK
without_bloocoo_restart_for_more_iterations  YES    # OK

#-- with bloocoo

with_bloocoo_restart_on_error                YES    # OK
with_bloocoo_restart_for_more_iterations     YES    # OK

#---------------------------------------------------------------------------------------
# Summary of assembly files to be checked
#---------------------------------------------------------------------------------------

#wc -l $WORKDIR/with*/run-*/assembly.fasta
myecho
myecho "md5sum of all assembly.fasta files (in the WORKDIR tree)..."
md5sum $WORKDIR/with*/run-*/assembly.fasta

myecho
myecho "List of assembly files to compare (to check results)..."
env | grep ASB_ | sort

ASB_LIST="`env | grep ASB_ | sort | cut -d= -f1`"

myecho
for ASB_FILE in $ASB_LIST; do
  eval "test -f \$$ASB_FILE"
  [ $? -eq 0 ] && { msg="found"; } || { msg="     !!! NOT found !!!"; }
  myecho "File $ASB_FILE $msg"
done
