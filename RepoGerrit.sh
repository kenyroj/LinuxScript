#!/bin/bash

# Param 2: heads or tags
DoGitPush() {
	GERRIT_HOST=$1

	echo "[`date +"%y%m%d-%H%M%S"`] Push refs/heads/* of $REPO_PROJECT"
	for n in $(git for-each-ref --format='%(refname)' refs/heads);
	do
		echo [`date +"%y%m%d-%H%M%S"`] -- $REPO_PROJECT: $n
		git push ssh://aken.hsu@$GERRIT_HOST:29418/$REPO_PROJECT $n;
	done

	echo "[`date +"%y%m%d-%H%M%S"`] Push refs/tags/* of $REPO_PROJECT"
	for n in $(git for-each-ref --format='%(refname)' refs/tags);
	do
		echo [`date +"%y%m%d-%H%M%S"`] -- $REPO_PROJECT: $n
		git push ssh://aken.hsu@$GERRIT_HOST:29418/$REPO_PROJECT $n;
	done
}

EachGitProject() {
	GERRIT_HOST=$1

	echo
	echo [`date +"%y%m%d %H%M%S"`] Gerrit Host:$GERRIT_HOST, Current Project: $REPO_PROJECT

	DoGitPush $GERRIT_HOST
}

EachGitProject $*

# ======== AKen: Try to run each branches of git by multi-processing. TBI. ========
DoEachLine() {
	PRJ_NAME=`echo $* | cut -d ' ' -f 1`
	PRJ_PATH=`echo $* | cut -d ' ' -f 2`
	GERRIT_HOST=`echo $* | cut -d ' ' -f 3`

	echo "PRJ=$PRJ_NAME : $PRJ_PATH @ $GERRIT_HOST"
	echo $REPO_HOME

	cd $PRJ_PATH
	echo [`date +"%Y%m%d-%H%M%S"`] Push refs/heads/* of $PRJ_NAME
	for n in $(git for-each-ref --format='%(refname)' refs/heads);
	do
		echo [`date +"%Y%m%d-%H%M%S"`] -- $PRJ_NAME: $n
		git push ssh://aken.hsu@$GERRIT_HOST:29418/$PRJ_NAME $n;
	done

	echo [`date +"%Y%m%d-%H%M%S"`] Push refs/tags/* of $PRJ_NAME
	for n in $(git for-each-ref --format='%(refname)' refs/tags);
	do
		echo [`date +"%Y%m%d-%H%M%S"`] -- $PRJ_NAME: $n
		git push ssh://aken.hsu@$GERRIT_HOST:29418/$PRJ_NAME $n;
	done
	cd $REPO_HOME
}

MultiProcessGitPush() {
	if [ -d ".repo" ] ; then
		export REPO_HOME=`pwd`
	else
		echo "Run this script in repo project, check the '.repo' folder"
		exit 1
	fi

	GERRIT_HOST=$1
	TMP_PRJ_FILE="/data/aken.hsu/XD.txt"
	while read line ; do
		DoEachLine $line $GERRIT_HOST
	done  < $TMP_PRJ_FILE

	echo XD Done
}


#GERRIT_HOST=$1
#MultiProcessGitPush $GERRIT_HOST
