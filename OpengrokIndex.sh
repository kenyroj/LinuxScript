#!/bin/bash

# in crontab, PATH was modified and need to add
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
OPENGROK_HOME=/data/opengrok

LogWithTime() {
	# echo [`date +"%m%d-%H%M%S"`] "$*"
	echo [`date +"%m%d-%H%M%S"`] "$*" >> $LOG_FILE
}

OpenGrokIndex() {
	# Backup Current indexed database and move it as temp.
	CMD="mv $SRC_DATA $TMP_DATA"
	LogWithTime Move Original database to TMP:
	LogWithTime "====> $CMD"
	$CMD >> $LOG_FILE 2>&1

	CMD="mv $SRC_CONF $TMP_CONF"
	LogWithTime Move Original config to TMP:
	LogWithTime "====> $CMD"
	$CMD >> $LOG_FILE 2>&1

	LogWithTime Start Indexing the codes and will cost about 1 Hr...
	export JAVA_OPTS="-Xmx8g -Xms8g"
	opengrok-indexer \
		-J=-Djava.util.logging.config.file=/opt/opengrok/doc/logging.properties \
		-a /opt/opengrok/lib/opengrok.jar -- \
		-s $SRC_PATH \
		-d $SRC_DATA \
		-H -P -S -G \
		-W $SRC_CONF >> $LOG_FILE 2>&1
	RET=$? ; if [ ! $RET = 0 ] ; then return $RET ; fi
}

ModifyHomepageImfo() {
	sed -i "/$ProjectName/c <td><a href=\"../$ProjectName\">$ProjectName</a></td><td>$1</td>" /var/lib/tomcat8/webapps/opengrok/index.html
}

CheckIndexOKorRestoreTemp() {
	if [ ! -f "$SRC_CONF" ] ; then
		LogWithTime "**** Indexing Failed, restore previous index... ****"

		CMD="mv $TMP_DATA $SRC_DATA"
		LogWithTime Move TMP database to Original:
		LogWithTime "====> $CMD"
		$CMD >> $LOG_FILE 2>&1

		CMD="mv $TMP_CONF $SRC_CONF"
		LogWithTime Move TMP config to Original:
		LogWithTime "====> $CMD"
		$CMD >> $LOG_FILE 2>&1
	else
		# remove temp database since indexing success.
		LogWithTime Remove Temp database and config...
		CMD="rm -rf $TMP_DATA $TMP_CONF"
		LogWithTime "====> $CMD"
		$CMD >> $LOG_FILE 2>&1
		ModifyHomepageImfo $INDEX_JOB_TIME
		LogWithTime OpenGrok finished indexing the codes and Success. Suggested to restart tomcat8 service.
	fi
}

RepoSyncProj() {
	cd $SRC_PATH
	rm opengrok*
	if [ -e "$NO_REPO_SYNC_FILE" ] ; then
		LogWithTime "Skip update codebase."
	elif [ -d ".git" ] ; then
		LogWithTime "Found .git, execute: git pull ..."
		$GIT pull >> $LOG_FILE 2>&1
	elif [ -d ".repo" ] ; then
		LogWithTime "Found .repo, execute: repo sync ..."
		$REPO sync >> $LOG_FILE 2>&1
	else
		LogWithTime "No need to update codebase for $EachF"
	fi
	
	LogWithTime "Remove All Symbolic links"
	find -L . -xtype l | grep -v '\.repo' | grep -v '\.git' | xargs rm -v >> $LOG_FILE 2>&1
}

Main() {
	if [ "$EUID" == "0" ] ; then
		LogWithTime " **** This script does not allow root. ****"
		return 1
	fi

	if [ -z $1 ] ; then
		echo Params is required.
		exit 1
	fi
	
	for EachPrj in $* ; do
		ProjectName=$EachPrj
		echo ProjectName=$ProjectName

		SRC_PATH=${OPENGROK_HOME}/source/"$ProjectName"
		SRC_DATA=${OPENGROK_HOME}/data/"$ProjectName"
		TMP_DATA=${OPENGROK_HOME}/data/"$ProjectName"_tmp
		SRC_CONF=${OPENGROK_HOME}/etc/"$ProjectName".xml
		TMP_CONF=${OPENGROK_HOME}/etc/"$ProjectName"_tmp.xml

		INDEX_JOB_TIME=`date +"%Y%m%d-%H%M%S"`
		LOG_FILE=${OPENGROK_HOME}/log/"$INDEX_JOB_TIME"-"$ProjectName".log

		ModifyHomepageImfo "Re-indexing"
		RepoSyncProj
		OpenGrokIndex $ProjectName
		CheckIndexOKorRestoreTemp
	done
}

Main $*
exit $?
