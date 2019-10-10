#!/bin/bash

# Param 3: heads or tags
DoGitPush() {
	GERRIT_HOST=$1
	PUSH_REF=$2

	echo -- Push refs/$PUSH_REF/*: $REPO_PROJECT
	for n in $(git for-each-ref --format='%(refname)' refs/$PUSH_REF);
	do
		echo ---- $REPO_PROJECT: $n
		git push ssh://aken.hsu@$GERRIT_HOST:29418/$REPO_PROJECT $n;
	done
#	git push ssh://aken.hsu@$GERRIT_HOST:29418/$REPO_PROJECT +refs/$PUSH_REF/*
}

EachGitProject() {
	PUSH_REF=$1
	GERRIT_HOST=$2

	echo
	echo [`date +"%y%m%d %H%M%S"`] Gerrit Host:$GERRIT_HOST, Current Project: $REPO_PROJECT

	DoGitPush $GERRIT_HOST $PUSH_REF
}

EachGitProject heads $*
EachGitProject tags $*
