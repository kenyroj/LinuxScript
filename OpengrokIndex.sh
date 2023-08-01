#!/bin/bash

# in crontab, PATH was modified and need to add
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
# export PATH=/usr/lib/jvm/jdk-11.0.6/bin:/usr/local/sbin:/usr/local/bin:$PATH
which java

OPENGROK_HOME=/data/OpenGROK

LogWithTime() {
	# echo [`date +"%m%d-%H%M%S"`] "$*"
	echo [`date +"%m%d-%H%M%S"`] "$*" >> $LOG_FILE 2>&1
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
	sed -i "/$ProjectName/c <td class=\"name\"><a href=\"../$ProjectName\">$ProjectName</a></td><td>$1</td><td>$2</td>" /var/lib/tomcat9/webapps/opengrok/index.html
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
		LogWithTime OpenGrok finished indexing the codes and Success. Suggested to restart tomcat service.
	fi
}

RepoSyncProj() {
	cd $SRC_PATH
	rm -f opengrok*
	if [ -e "$NO_REPO_SYNC_FILE" ] ; then
		LogWithTime "Skip update codebase."
	elif [ -d ".git" ] ; then
		LogWithTime "Found .git, execute: git pull ..."
		git checkout . >> $LOG_FILE 2>&1
		git clean -xdf >> $LOG_FILE 2>&1
		git pull >> $LOG_FILE 2>&1
	elif [ -d ".repo" ] ; then
		LogWithTime "Found .repo, execute: repo sync ..."
		repo sync -cdq --no-tags --no-repo-verify --no-clone-bundle --jobs=2 >> $LOG_FILE 2>&1
	else
		LogWithTime "No need to update codebase for $EachF"
	fi
}

PreRepoSync() {
	if [ ! -d "$SRC_PATH/.repo/manifests" ] ; then return ; fi

	cd $SRC_PATH/.repo/manifests
	Manifest=`readlink default.xml`
	if [ -z $Manifest ] ; then Manifest="default.xml" ; fi

	git co .
	git pull

	sed -i '/name=\"kernel\/msm-/d' $Manifest
	sed -i '/name=\"platform\/cts/d' $Manifest
	sed -i '/name=\"platform\/external/d' $Manifest
	sed -i '/name=\"platform\/prebuilts/d' $Manifest
	sed -i '/name=\"platform\/libcore/d' $Manifest
	sed -i '/name=\"platform\/libnativehelper/d' $Manifest
	sed -i '/name=\"platform\/platform_testing/d' $Manifest
	sed -i '/name=\"platform\/pdk/d' $Manifest
	sed -i '/name=\"toolchain/d' $Manifest
	sed -i '/path=\"art/d' $Manifest
	sed -i '/path=\"bionic/d' $Manifest
	sed -i '/path=\"bootable\/bootloader\/edk2/d' $Manifest
	sed -i '/path=\"dalvik/d' $Manifest
	sed -i '/path=\"developers/d' $Manifest
	sed -i '/path=\"development/d' $Manifest
	sed -i '/path=\"shortcut-fe/d' $Manifest
	sed -i '/path=\"test/d' $Manifest
	sed -i '/path=\"tools/d' $Manifest
	sed -i '/path=\"vendor\/qcom\/proprietary/d' $Manifest
	sed -i '/name=\"kernel\/configs/d' $Manifest
	sed -i '/name=\"kernel\/tests/d' $Manifest
	sed -i '/name=\"qcom\/nhlos\/btfm_proc/d' $Manifest
	sed -i '/name=\"qcom\/nhlos\/modem_proc/d' $Manifest
	sed -i '/name=\"qcom\/nhlos\/venus_proc/d' $Manifest
	sed -i '/name=\"qcom\/nhlos\/wdsp_proc/d' $Manifest
	sed -i '/name=\"qcom\/nhlos\/wlan_proc/d' $Manifest
	sed -i '/name=\"mitac\/region_image/d' $Manifest
	sed -i '/<linkfile /d' $Manifest
	
	rm -rf sdk
}

PreIndex() {
	#LogWithTime "==== Remove All Symbolic links ===="
	#find -L . -xtype l | grep -v '\.repo' | grep -v '\.git' | xargs rm -v >> $LOG_FILE 2>&1

	cd $SRC_PATH
	rm -f opengrok*
}

PostIndex() {
	if [ ! -d "$SRC_PATH/.repo/manifests" ] ; then return ; fi
	cd $SRC_PATH/.repo/manifests
	Manifest=`readlink default.xml`
	git co $Manifest
	cd $SRC_PATH
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
		BeginTime=`date +%s`

		ProjectName=$EachPrj
		echo ProjectName=$ProjectName

		SRC_PATH=${OPENGROK_HOME}/source/"$ProjectName"
		SRC_DATA=${OPENGROK_HOME}/data/"$ProjectName"
		TMP_DATA=${OPENGROK_HOME}/data/"$ProjectName"_tmp
		SRC_CONF=${OPENGROK_HOME}/etc/"$ProjectName".xml
		TMP_CONF=${OPENGROK_HOME}/etc/"$ProjectName"_tmp.xml
		TMP_FOLDER=${OPENGROK_HOME}/.temp
		SkipFolders="art bionic dalvik developers development disregard external libcore libnativehelper pdk platform_testing prebuilts sdk shortcut-fe test toolchain tools"

		INDEX_JOB_TIME=`date +"%Y%m%d-%H%M%S"`
		LOG_FILE=${OPENGROK_HOME}/log/"$INDEX_JOB_TIME"-"$ProjectName".log

		ModifyHomepageImfo "Re-indexing" "NotAvail"

		PreRepoSync
		RepoSyncProj
		PreIndex
		OpenGrokIndex $ProjectName
#		echo Indexing ; sleep 10
		PostIndex

		EndTime=`date +%s`
		CostTime=`date -d@$((EndTime-BeginTime)) -u +%H:%M:%S`
		ModifyHomepageImfo $INDEX_JOB_TIME $CostTime

		CheckIndexOKorRestoreTemp

	done
}

Main $*
exit $?
