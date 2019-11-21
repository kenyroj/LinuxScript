#!/bin/bash

# in crontab, PATH was modified and need to add
export PATH=/usr/local/sbin:/usr/local/bin:$PATH

IDX_ROOT=/data/opengrok
IDX_DATA=${IDX_ROOT}/data
IDX_CONF=${IDX_ROOT}/etc/configuration.xml
TMP_DATA=${IDX_ROOT}/data_tmp
TMP_CONF=${IDX_ROOT}/etc/configuration_tmp.xml
SRC_PATH=${IDX_ROOT}/src
INDEX_JOB_TIME=`date +"%Y%m%d-%H%M%S"`
LOG_FILE=${IDX_ROOT}/log/$INDEX_JOB_TIME.log
BACKUP_PATH=${IDX_ROOT}/backup

function LogWithTime() {
	# echo [`date +"%m%d-%H%M%S"`] "$*"
	echo [`date +"%m%d-%H%M%S"`] "$*" >> $LOG_FILE
}

function BackupDatabase() {
	cd $IDX_ROOT
	CMD="tar zcvf backup/${INDEX_JOB_TIME}.tgz data etc"
	LogWithTime Backup Original database and config:
	LogWithTime "====> $CMD"
	$CMD >> /dev/null 2>&1

#	KEEP_BACKUP=5
#	CMD="ls -td \"${BACKUP_PATH}/*\" | sed -e '1,${KEEP_BACKUP}d' | /usr/bin/xargs -d '\n' rm"
#	LogWithTime Remove Old backups and keep $KEEP_BACKUP files
#	LogWithTime "====> $CMD"
#	$CMD >> $LOG_FILE 2>&1
}

function OpenGrokIndex() {
	# Backup Current indexed database and move it as temp.
	CMD="mv $IDX_DATA $TMP_DATA"
	LogWithTime Move Original database to TMP:
	LogWithTime "====> $CMD"
	$CMD >> $LOG_FILE 2>&1

	CMD="mv $IDX_CONF $TMP_CONF"
	LogWithTime Move Original config to TMP:
	LogWithTime "====> $CMD"
	$CMD >> $LOG_FILE 2>&1

	LogWithTime Start Indexing the codes and will cost about 1 Hr...
	export JAVA_OPTS=-Xmx4096m
	time opengrok-indexer \
		-J=-Djava.util.logging.config.file=/opt/opengrok-1.3.1/doc/logging.properties \
		-a /opt/opengrok/lib/opengrok.jar -- \
		-s $SRC_PATH \
		-d $IDX_DATA \
		-H -P -S -G \
		-W $IDX_CONF >> $LOG_FILE 2>&1
}

function CheckIndexOKorRestoreTemp() {
	if [ ! -f "$IDX_CONF" ] ; then
		LogWithTime "**** Indexing Failed, restore previous index... ****"

		CMD="mv $TMP_DATA $IDX_DATA"
		LogWithTime Move TMP database to Original:
		LogWithTime "====> $CMD"
		$CMD >> $LOG_FILE 2>&1

		CMD="mv $TMP_CONF $IDX_CONF"
		LogWithTime Move TMP config to Original:
		LogWithTime "====> $CMD"
		$CMD >> $LOG_FILE 2>&1
	else
		# remove temp database since indexing success.
		CMD="rm -rf $TMP_DATA $TMP_CONF"
		LogWithTime Remove Temp database and config:
		LogWithTime "====> $CMD"
		$CMD >> $LOG_FILE 2>&1

		LogWithTime OpenGrok finished indexing the codes and Success. Suggested to restart tomcat8 service.
		BackupDatabase
	fi
}

function RepoSyncAllProj() {
	REPO=`which repo`
	GIT=`which git`
	NO_REPO_SYNC_FILE=".no_repo_sync_for_opengrok"
	for EachF in "$SRC_PATH"/* ; do
		if [ -d "$EachF" ] ; then
			cd $EachF
			# If the project folder contains the $NO_REPO_SYNC_FILE, skip renew codebase
			if [ -e "$NO_REPO_SYNC_FILE" ] ; then
				LogWithTime "In $EachF, skip update codebase."
			elif [ -d ".git" ] ; then
				LogWithTime "Found .git in $EachF, execute: git pull ..."
				$GIT pull >> $LOG_FILE 2>&1
			elif [ -d ".repo" ] ; then
				LogWithTime "Found .repo in $EachF, execute: repo sync ..."
				$REPO sync >> $LOG_FILE 2>&1
			else
				LogWithTime "No need to update codebase for $EachF"
			fi
		fi
	done
	LogWithTime Finished the codebase syncing.
}

# ==== Main function starts here ====
if [ "$EUID" == "0" ] ; then
  LogWithTime " **** This script does not allow root. ****"
  exit 1
fi

RepoSyncAllProj
# OpenGrokIndex
CheckIndexOKorRestoreTemp

