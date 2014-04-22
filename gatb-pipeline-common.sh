#!/bin/bash

echo
echo "Sourcing gatb-pipeline-common.sh ..."
echo


MAIL_DST_ALL_MESG=charles.deltel@inria.fr
MAIL_DST_ERR_ONLY="cdeltel@laposte.net rchikhi@gmail.com"

MAIL_CMD="ssh igrida-oar-frontend mail "

#LOGBOOK=/udd/cdeltel/bioinfo/anr-gatb/logbook-${PIP}.txt   => Currently read-only file system!
LOGBOOK=/temp_dd/igrida-fs1/cdeltel/bioinfo/logbook-${PIP}.txt
TODAY=`date +'%Y/%m/%d'`

#------------------------------------------------------------------------------
# Data paths
#------------------------------------------------------------------------------
DATA_GENOUEST=   

case "$PIP" in
        p1) DATA_NAME=Assemblathon1/data ;;
        p2) DATA_NAME=chr14-gage ;; 
        p3) DATA_NAME=Staphylococcus_aureus/Data/original ;; 
        p4) DATA_NAME=Rhodobacter_sphaeroides/Data/original ;; 
        p5) DATA_NAME=Bombus_impatiens/Data/original ;;   # données à vérifier ???
        p6) DATA_NAME=Assemblathon2/fish/fastq ;; 
		*)  echo Error; exit 1; ;;
esac

DATA_IGRIDA=/temp_dd/igrida-fs1/cdeltel/bioinfo/${DATA_NAME}/
REPORTS_GENOUEST=/home/symbiose/cdeltel/anr-gatb/reports/igrida/gatb-${PIP}/

#------------------------------------------------------------------------------
# Host infos
#------------------------------------------------------------------------------
lstopo --of txt

#------------------------------------------------------------------------------
# Tools
#------------------------------------------------------------------------------
duration() {
	local dt=${1}
	((h=dt/3600))
	((m=dt%3600/60))
	((s=dt%60))
	printf "%03dh:%02dm:%0ds\n" $h $m $s
}

#------------------------------------------------------------------------------
# Job infos
#------------------------------------------------------------------------------
EXT_print_job_informations() {
	echo "hostname        : " `hostname`
	echo "TODAY           : $TODAY"
	echo "OAR_JOB_NAME    : $OAR_JOB_NAME"
	echo "OAR_JOB_ID      : $OAR_JOB_ID"
	echo "OAR_ARRAY_ID    : $OAR_ARRAY_ID"
	echo "OAR_ARRAY_INDEX : $OAR_ARRAY_INDEX"
}

EXT_send_starting_mail() {
	SUBJECT="[gatb-${PIP}]-job$OAR_JOB_ID-starts"
	$MAIL_CMD $MAIL_DST_ALL_MESG -s "$SUBJECT" << EOF
OAR_JOB_ID: $OAR_JOB_ID - hostname: `hostname`
EOF
}

#------------------------------------------------------------------------------
# Send an e-mail when job starts/ends
#------------------------------------------------------------------------------
EXT_send_ending_mail() {
	echo "JOB_SUMMARY"
	SUBJECT="[gatb-${PIP}]-job$OAR_JOB_ID-ends-`duration $DURATION_TIME`"
	$MAIL_CMD $MAIL_DST_ALL_MESG -s "$SUBJECT" << EOF
$JOB_SUMMARY
EOF
	if [ $CMD_EXIT_CODE -ne 0 ] || [ $MAKE_EXIT_CODE -ne 0 ]; then
		SUBJECT="[gatb-${PIP}]-job$OAR_JOB_ID-ends-Error"
		$MAIL_CMD $MAIL_DST_ALL_MESG $MAIL_DST_ERR_ONLY -s "$SUBJECT" << EOF
This is to inform you that the GATB ${PIP} pipeline exited with error: 
	MAKE_EXIT_CODE: $MAKE_EXIT_CODE
	CMD_EXIT_CODE:  $CMD_EXIT_CODE
EOF
	fi
}

#------------------------------------------------------------------------------
# Download the code
#------------------------------------------------------------------------------
EXT_download_source_code() {
	git clone git+ssh://cdeltel@scm.gforge.inria.fr//gitroot/gatb-pipeline/gatb-pipeline.git git-gatb-pipeline
	[ $? -ne 0 ] && { echo "git clone error"; exit 1;}
	svn co svn+ssh://scm.gforge.inria.fr/svnroot/projetssymbiose/superscaffolder             superscaffolder
	[ $? -ne 0 ] && { echo "svn co error"; exit 1;}
	svn co svn+ssh://scm.gforge.inria.fr/svnroot/projetssymbiose/minia/trunk                 debloom
	[ $? -ne 0 ] && { echo "svn co error"; exit 1;}
	svn co svn+ssh://scm.gforge.inria.fr/svnroot/projetssymbiose/specialk                    specialk
	[ $? -ne 0 ] && { echo "svn co error"; exit 1;}
}

#------------------------------------------------------------------------------
# Code versioning informations
#------------------------------------------------------------------------------
EXT_print_versioning_informations() {
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
}

#------------------------------------------------------------------------------
# Define where the run will take place
#------------------------------------------------------------------------------
EXT_define_paths() {
	#NOW=$(date +"%Y-%m-%d-%H:%M:%S")

	#WORKDIR=/temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/p2/2013-07-29-17:50:29
 	WORKDIR=/temp_dd/igrida-fs1/cdeltel/bioinfo/gatb-pipeline-runs/${PIP}/$OAR_JOB_ID
	
	PIPELINE=$WORKDIR/gatb-pipeline
	GATB_SCRIPT=$PIPELINE/git-gatb-pipeline/gatb
	MEMUSED=$PIPELINE/git-gatb-pipeline/tools/memused
	chmod a+x $MEMUSED
	QUAST_PATH=/udd/cdeltel/bioinfo/quast-2.2/
	QUAST_CMD="python $QUAST_PATH/quast.py "
}


#------------------------------------------------------------------------------
# Non regression tests
#------------------------------------------------------------------------------


EXT_non_regression_update_logbook(){
	OAR_JOB_ID_PREVIOUS="`tail -1 $LOGBOOK|awk '{print $2}'`"
	START_TIME_PREVIOUS="`tail -1 $LOGBOOK|awk '{print $8}'`"
	END_TIME_PREVIOUS="`tail -1 $LOGBOOK|awk '{print $11}'`"

	(( DURATION_TIME_PREVIOUS = END_TIME_PREVIOUS - START_TIME_PREVIOUS ))
	(( DT_WITH_PREVIOUS = DURATION_TIME - DURATION_TIME_PREVIOUS ))

	JOB_SUMMARY="TODAY: $TODAY - OAR_JOB_ID: $OAR_JOB_ID - hostname: `hostname` - START_TIME: $START_TIME - END_TIME: $END_TIME - DURATION: `duration $DURATION_TIME` - CMD_EXIT_CODE: $CMD_EXIT_CODE - DT_WITH_PREVIOUS: $DT_WITH_PREVIOUS"
	echo "$JOB_SUMMARY" >> $LOGBOOK
}

EXT_non_regression_quast() {
	echo "EXT_non_regression_quast: Not ready"

	quast_latest=$WORKDIR/../$OAR_JOB_ID_PREVIOUS/run/quast_results/latest/quast.log
	quast_current=$WORKDIR/run/quast_results/latest/quast.log

	echo 
	echo We compare $quast_latest and $quast_current
	echo

	diff $quast_latest $quast_current

	echo

	if [ $? -ne 0 ]; then
		echo
		echo "WARNING: Quast results differ from previous run!"
		echo
	fi
}

EXT_non_regression_execution_time() {
	echo "EXT_non_regression_execution_time: TODO"
}

#------------------------------------------------------------------------------
# Upload run reports to Genouest
#------------------------------------------------------------------------------

EXT_transfer_reports_to_genouest() {

	ssh genocluster2 mkdir -p $REPORTS_GENOUEST/outjobs
	ssh genocluster2 mkdir -p $REPORTS_GENOUEST/quast

	rsync -uv $WORKDIR/../outjobs/*									genocluster2:$REPORTS_GENOUEST/outjobs/
	rsync -uv $WORKDIR/run/quast_results/results_*/report.txt		genocluster2:$REPORTS_GENOUEST/quast/report.$OAR_JOB_ID.txt
	
	rsync -uv $LOGBOOK												genocluster2:$REPORTS_GENOUEST/outjobs/logbook-${PIP}.txt
	
}

