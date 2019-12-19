#!/bin/bash

MANIFEST_TIME=`date +"%Y%m%d-%H0000"`
MANIFEST_HOME=/data/DailyManifest
ANDROID_HOME=$MANIFEST_HOME/Android
JENKINS_AUTH=aken.hsu:113b15aa56bf22143b19e7696483be42c6
JENKINS_URL=10.88.26.14:8080
JENKINS_TOKEN=APBC_RDD5.MDT
LOG_HOME=$MANIFEST_HOME/log
LOG_NAME=$LOG_HOME/$MANIFEST_TIME.log

LogWithTime() {
	echo [`date +"%m%d-%H%M%S"`] "$*"
	echo [`date +"%m%d-%H%M%S"`] "$*" >> $LOG_NAME 2>&1
}

HandleEachRepo() {
	cd $ANDROID_HOME
	LogWithTime =============================================================================
	REPO=$1
	BRANCH_NAME=`cat $REPO | cut -d " " -f 6`
	PRODUCT_NAME="${BRANCH_NAME%-*}"
	LogWithTime BRANCH_NAME=$BRANCH_NAME, PRODUCT_NAME=$PRODUCT_NAME, RepoDoc=$REPO
	
	# repo sync the codebase to the newest status
	LogWithTime repo_cmd: `cat $REPO`
	`cat $REPO` >> $LOG_NAME 2>&1
	repo sync -c -j4 >> $LOG_NAME 2>&1

	cd .repo/manifests/daily
	# Find the newest manifest before generate
	unset -v LastestFile
# Find the lastest accessed File, but All the manifests are loaded at the same time. So comment it.
#	for EachF in ./* ; do
#		[[ $EachF -nt $LastestFile ]] && LastestFile=$EachF
#	done
	LastestFile=`ls | tail -1`
	LogWithTime The lastest manifest is $LastestFile
	
	# Generate daily menifest, the minutes and seconds set to 0 for convinience
	LogWithTime Generate the manifest: $MANIFEST_TIME.xml
	repo manifest -r -o $MANIFEST_TIME.xml --suppress-upstream  >> $LOG_NAME 2>&1
	
	# Push the new manifest to Gerrit
	git add $MANIFEST_TIME.xml >> $LOG_NAME 2>&1
	git commit -m "Add daily manifest: $MANIFEST_TIME.xml" >> $LOG_NAME 2>&1
	LogWithTime " ===> git push gerrit://main.apbcrdd5.mdt/manifest HEAD:refs/heads/$BRANCH_NAME"
	git push gerrit://main.apbcrdd5.mdt/manifest HEAD:refs/heads/$BRANCH_NAME >> $LOG_NAME 2>&1
	
	# If manifest is not the same with the newest manifest, Trigger daily build
	diff $LastestFile $MANIFEST_TIME.xml
	DiffResult=$?
	TRIGGER_BUILD_URL="http://${JENKINS_AUTH}@${JENKINS_URL}/job/$PRODUCT_NAME/buildWithParameters?token=${JENKINS_TOKEN}&BranchName=${BRANCH_NAME}&DailyManifest=${MANIFEST_TIME}&BuildVariant=userdebug&BuildDist=true"
	if [ $DiffResult -ne 0 ] ; then
		LogWithTime Manifest changed. Trigger daily build...
		curl -I -X POST "$TRIGGER_BUILD_URL" >> $LOG_NAME 2>&1
	else
		LogWithTime Manifest not changed. Skip trigger daily build.
	fi
	LogWithTime - Trigger Build URL: $TRIGGER_BUILD_URL
}
HandleAndroid() {
	cd $ANDROID_HOME
	REPOS=`ls repo*`
	for EachRepo in $REPOS ; do
		HandleEachRepo $EachRepo
	done
}

Main() {
	HandleAndroid
}

Main
