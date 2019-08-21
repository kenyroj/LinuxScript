#!/bin/bash

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


