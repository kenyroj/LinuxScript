#!/bin/bash

function HeadsPush() {
	REPO_HOME=`pwd`
	REPO_PROJECT=$1
	REPO_PATH=$2
	THIS_MONTH=`date +"%y%m"`
	REPO_OK_FILE=.$THIS_MONTH.repo_head_OK

	cd $REPO_PROJECT.git
	if [ -f $REPO_OK_FILE ] ; then
		ExeCmd echo -------- This project $REPO_PROJECT was up-to-date and do nothing.
	else
		ExeCmd echo ========> Push refs/heads/*: $REPO_PROJECT
		ExeCmd git push ssh://aken.hsu@localhost:29418/$REPO_PROJECT +refs/heads/*
		RET=$?
		echo Last Returned = $RET
		if [ "$RET" = "0" ] ; then
			ExeCmd echo ========--> Projrct $REPO_PROJECT pushed successfully.
			ExeCmd echo touch $REPO_OK_FILE
		else
			ExeCmd echo ========--> Projrct $REPO_PROJECT pushed FAIL with RET=$RET
		fi
	fi
	cd $REPO_HOME

}
