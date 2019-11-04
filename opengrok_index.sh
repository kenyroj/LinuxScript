#!/bin/bash

# in crontab, PATH was modified and need to add
export PATH=/usr/local/sbin:/usr/local/bin:$PATH

IDX_ROOT=/data/opengrok/.opengrok
IDX_DATA=${IDX_ROOT}/data
IDX_CONF=${IDX_ROOT}/etc/configuration.xml
TMP_DATA=${IDX_ROOT}/data_tmp
TMP_CONF=${IDX_ROOT}/etc/configuration_tmp.xml
SRC_PATH="/data/opengrok"
NOW_TIME=`date +"%Y%m%d-%H%M%S"`
LOG_FILE=${IDX_ROOT}/log/$NOW_TIME.log
BACKUP_PATH=${IDX_ROOT}/backup

function LogWithTime() {
	# echo [`date +"%m%d-%H%M%S"`] "$*"
	echo [`date +"%m%d-%H%M%S"`] "$*" >> $LOG_FILE
}

function BackupDatabase() {
	CMD="tar zcvf ${BACKUP_PATH}/${NOW_TIME}.tgz $IDX_DATA $IDX_CONF"
	LogWithTime Backup Original database and config:
	LogWithTime "====> $CMD"
	$CMD >> /dev/null 2>&1

#	KEEP_BACKUP=5
#	CMD="ls -td \"${BACKUP_PATH}/*\" | sed -e '1,${KEEP_BACKUP}d' | /usr/bin/xargs -d '\n' rm"
#	LogWithTime Remove Old backups and keep $KEEP_BACKUP files
#	LogWithTime "====> $CMD"
#	$CMD >> $LOG_FILE 2>&1

	CMD="rm -rf $TMP_DATA $TMP_CONF"
	LogWithTime Remove Temp database and config:
	LogWithTime "====> $CMD"
	$CMD >> $LOG_FILE 2>&1

	CMD="mv $IDX_DATA $TMP_DATA"
	LogWithTime Move Original database to TMP:
	LogWithTime "====> $CMD"
	$CMD >> $LOG_FILE 2>&1

	CMD="mv $IDX_CONF $TMP_CONF"
	LogWithTime Move Original config to TMP:
	LogWithTime "====> $CMD"
	$CMD >> $LOG_FILE 2>&1
}

function OpenGrokIndex() {
	LogWithTime Start Indexing the codes and will cost about 1 Hr...
	export JAVA_OPTS=-Xmx4096m -Xmx4096
	time opengrok-indexer \
		-J=-Djava.util.logging.config.file=/opt/opengrok-1.3.1/doc/logging.properties \
		-a /opt/opengrok/lib/opengrok.jar -- \
		-s /data/opengrok \
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
	fi
}

function RepoSyncAllProj() {
	REPO=`which repo`
	for EachF in "$SRC_PATH"/* ; do
		if [ -d "$EachF" ] ; then
			cd $EachF
			if [ -e ".no_opengrok" ] ; then
				LogWithTime "In $EachF, Skip repo sync."
			else
				LogWithTime "In $EachF, Execute: repo sync..."
				$REPO sync >> $LOG_FILE 2>&1
			fi
		fi
	done
}


if [ "$EUID" == "0" ] ; then
  LogWithTime " **** This script does not allow root. ****"
  exit 1
fi

RepoSyncAllProj
BackupDatabase
OpenGrokIndex
CheckIndexOKorRestoreTemp
LogWithTime OpenGrok finished indexing the codes. Now can restart tomcat8.

