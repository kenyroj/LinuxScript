#!/bin/bash

# Param 3: heads or tags
DoGitPush() {
	GERRIT_HOST=$1
	HEAD_OK_FILE=$2
	PUSH_REF=$3

	echo -- Push refs/$PUSH_REF/*: $REPO_PROJECT
	for n in $(git for-each-ref --format='%(refname)' refs/$PUSH_REF);
	do
		echo ---- $n
		git push ssh://aken.hsu@$GERRIT_HOST:29418/$REPO_PROJECT $n;
	done
#	git push ssh://aken.hsu@$GERRIT_HOST:29418/$REPO_PROJECT +refs/$PUSH_REF/*
#	RET=$?
#	if [ "$RET" = "0" ] ; then
#		echo == Projrct $REPO_PROJECT pushed successfully.
#		touch $HEAD_OK_FILE
#	else
#		echo == Projrct $REPO_PROJECT pushed FAIL with RET=$RET
#	fi
}

EachGitProject() {
	PUSH_REF=$1
	GERRIT_HOST=$2
	THIS_MONTH=`date +"%y%m"`
	HEAD_OK_FILE=`pwd`/.$THIS_MONTH.repo_$PUSH_REF_OK

	echo
	echo [`date +"%y%m%d %H%M%S"`] Gerrit Host:$GERRIT_HOST, Current Project: $REPO_PROJECT
#	exit 0

	if [ -f $HEAD_OK_FILE ] ; then
		echo -- Project $REPO_PROJECT was up-to-date and do nothing.
	else
		DoGitPush $GERRIT_HOST $HEAD_OK_FILE $PUSH_REF
	fi
}

EachGitProject heads $*
EachGitProject tags $*
