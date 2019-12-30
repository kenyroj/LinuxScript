#!/bin/bash

MANIFEST_TIME=""
MANIFEST_HOME=/data/DailyManifest

ANDROID_HOME=$MANIFEST_HOME/Android
AMBARELLA_HOME=$MANIFEST_HOME/Ambarella

JENKINS_AUTH=aken.hsu:113b15aa56bf22143b19e7696483be42c6
JENKINS_URL=mdt-apbc-rd5-build01.mic.com.tw:8080
JENKINS_TOKEN=APBC_RDD5.MDT

AddManifestToGerrit() {
	git add $ManifestFile
	git commit -m "Add daily manifest of $MANIFEST_TIME"
	echo " ===> git push gerrit://main.apbcrdd5.mdt/manifest HEAD:refs/heads/$BRANCH_NAME"
	git push gerrit://main.apbcrdd5.mdt/manifest HEAD:refs/heads/$BRANCH_NAME
}

HandleEachRepo() {
	echo =============================================================================
	REPO=$1
	BRANCH_NAME=`cat $REPO | cut -d " " -f 6`
	PRODUCT_NAME="${BRANCH_NAME%-*}"
	echo BRANCH_NAME=$BRANCH_NAME, PRODUCT_NAME=$PRODUCT_NAME, RepoDoc=$REPO
	
	# repo sync the codebase to the newest status
	echo repo_cmd: `cat $REPO`
	`cat $REPO`
	repo sync -c -j4

	MANIFEST_TIME=`date +"%Y%m%d-%H%M00"`
	cd .repo/manifests/daily
	# Find the newest manifest before generate
	unset -v LastestFile
	LastestFile=`ls | tail -1`
	echo The lastest manifest is $LastestFile
	
	# Generate daily menifest, the minutes and seconds set to 0 for convinience
	ManifestFile="$MANIFEST_TIME.xml"
	echo Generate the manifest: $ManifestFile
	repo manifest -r -o $ManifestFile --suppress-upstream
	
	# Push the new manifest to Gerrit
	AddManifestToGerrit

	# If manifest is not the same with the newest manifest, Trigger daily build
	diff $LastestFile $ManifestFile
	DiffResult=$?
	TRIGGER_BUILD_URL="http://${JENKINS_AUTH}@${JENKINS_URL}/job/$PRODUCT_NAME/buildWithParameters?token=${JENKINS_TOKEN}&BranchName=${BRANCH_NAME}&DailyManifest=${MANIFEST_TIME}&BuildVariant=userdebug&BuildDist=true"
	if [ $DiffResult -ne 0 ] ; then
		echo Manifest changed. Trigger daily build...
		curl -I -X POST "$TRIGGER_BUILD_URL"
	else
		echo Manifest not changed. Skip trigger daily build.
	fi
	echo - Trigger Build URL: $TRIGGER_BUILD_URL
}
HandleAndroid() {
	cd $ANDROID_HOME
	REPOS=`ls repo*`
	for EachRepo in $REPOS ; do
		HandleEachRepo $EachRepo
	done
}
HandleAmbarella() {
	cd $AMBARELLA_HOME
	REPOS=`ls repo*`
	for EachRepo in $REPOS ; do
		HandleEachRepo $EachRepo
	done
}

Main() {
	HandleAmbarella
#	HandleAndroid
}

Main
