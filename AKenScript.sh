#!/bin/bash

function KeepNewNFiles() {
	if test $# -eq 0 ; then
		echo "USAGE: $0 <<Numbers of files to keep>>"
		exit 1
	fi
	NumToKeep=$1
	Cmd="ls -t | sed -e '1,${NumToKeep}d' | /usr/bin/xargs -d '\n' rm"
#	Cmd=rm `ls -t | awk 'NR>5'`
	echo Run this command: ${COL_YLW} $Cmd${COL_NON}
#	ExeCmd $Cmd
}

function ChOwnGrp() {
	chown $*
	chgrp $*
}

export GERRIT_USER=aken.hsu
export GERRIT_HOST=10.88.26.15
function CmdGerrit() {
	Cmd="ssh -p 29418 ${GERRIT_USER}@${GERRIT_HOST} gerrit $*"
	ExeCmd $Cmd
}
function PushHeadTagByGit() {
	PROJ_NAME=$1
	for n in $(git for-each-ref --format='%(refname)' refs/heads) ; do
		echo [`date +"%m%d-%H%M%S"`] - $n @ $PROJ_NAME
		Cmd="git push ssh://${GERRIT_USER}@${GERRIT_HOST}:29418/${PROJ_NAME} $n"
		ExeCmd $Cmd
	done
	for n in $(git for-each-ref --format='%(refname)' refs/tags) ; do
		echo [`date +"%m%d-%H%M%S"`] - $n @ $PROJ_NAME
		Cmd="git push ssh://${GERRIT_USER}@${GERRIT_HOST}:29418/${PROJ_NAME} $n"
		ExeCmd $Cmd
	done
	echo Push heads and tags of $PROJ_NAME Finished.
}
function DelGerritProj() {
	for EachGit in $* ; do
		Cmd="ssh -p 29418 ${GERRIT_USER}@${GERRIT_HOST} delete-project delete --yes-really-delete $EachGit"
		ExeCmd $Cmd
	done;
}

function CCat() {
	local style="monokai"
	if [ $# -eq 0 ] ; then
		pygmentize -P style=$style -P tabsize=4 -f terminal256 -g
	else
		for NAME in $@ ; do
			pygmentize -P style=$style -P tabsize=4 -f terminal256 -g "$NAME"
		done
	fi
}

function NoCtrlM () {
	if test $# -eq 0 ; then
		echo "USAGE: $0 filename [filename1 [filename2 ...]]"
		exit 1
	fi

	for each in $* ; do
		tmpFile=tmpFile$RANDOM
		ls -l $each
		cat $each | tr -d '\r' > $tmpFile
		cat $tmpFile > $each
		ls -l $each
		rm -f $tmpFile
	done
}

function gitSt() {
	CODEROOT=$PWD

	for EachGit in $GitPRJ ; do
		if [ -d "${EachGit}" ]; then
			echo " $COLOR_YLW====>$COLOR_NON Checking git:$COLOR_LAK $EachGit $COLOR_NON"
			cd $EachGit
			git status | grep modified
			cd $CODEROOT
		else
			echo " $COLOR_GRY==X project path $COLOR_BLU$EachGit$COLOR_GRY not existed. $COLOR_NON"
		fi
	done
}

function QGitST() {
	GitPRJ="
		kernel/msm-4.4
		kernel/msm-4.9
		device/yandex
		device/qcom/sdm660_64
		bootable/bootloader/edk2
		bootable/bootloader/lk
		hardware/qcom/display
		hardware/qcom/camera
		vendor/qcom/proprietary
		system/sepolicy
		device/qcom/sepolicy
	"

	gitSt ${GitPRJ}
}

function RepoSync() {
	ExeCmd repo sync -cq --no-tags --no-repo-verify -j8 $*
}

function DiskUsage() {
	ExeCmd du -h --max-depth=1 $*
}


