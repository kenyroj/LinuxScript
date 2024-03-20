#!/bin/bash

ListPkg() {
	SHORT_HOST=`echo $HOSTNAME | rev | cut -d '-' -f 1 | rev`
	sudo apt list --installed > /mnt/nfs/Share/ToAken/PKGs.${SHORT_HOST}
}

KeepNewNFiles() {
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

ChOwnGrp() {
	chown $*
	chgrp $*
}

SmbUser() {
	ExeCmd pdbedit -L $* | sort
}

CCat() {
	local style="monokai"
	if [ $# -eq 0 ] ; then
		pygmentize -P style=$style -P tabsize=4 -f terminal256 -g
	else
		for NAME in $@ ; do
			pygmentize -P style=$style -P tabsize=4 -f terminal256 -g "$NAME"
		done
	fi
}

NoCtrlM () {
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

Gst() {
	CODEROOT=$PWD

	for EachGit in $GitPRJ ; do
		if [ -d "${EachGit}" ]; then
			echo " $COL_YLW====>$COL_NON Checking git:$COL_LAK $EachGit $COL_NON"
			cd $EachGit
			# git ls-files -om
			git status --short
			cd $CODEROOT
		else
			echo " $COL_GRY==X project path $COL_BLU$EachGit$COL_GRY not existed. $COL_NON"
		fi
	done
}

ErrBuild() {
	if [ -z $1 ] ; then
		LogName=_Latest.log
	else
		LogName=$1
	fi
	if [ ! -f $LogName ] ; then
		echo "File not found: $LogName"
		return 1
	fi

	grep -v "object directory" $LogName \
		| grep -v 'Following validations failed for the image' \
		| grep -v 'Image operation has not been enabled' \
		| grep -v 'Image operation failed for image' \
		| grep -v 'python command returned error' \
		| grep -v 'Traceback (most recent call last)'  \
		| grep -v " Could not read" \
		| grep -v " TEMP_FAILURE_RETRY" \
		| grep -v " DEBUG_PRINT" \
		| grep -n \
			-e " error:" \
			-e " ERROR:" \
			-e FAIL \
			-e "ISO C90 forbids" \
			-e "forbidden warning" \
			-e "neverallow check failed" \
			-e "ERROR 'unknown type" \
			-e "dtbo: ERROR" \
			-e "No space left on device" \
			-e 'out/\.lock'
}

Glg() {
	git log --date=format:'%Y%m%d_%H%M%S' --no-merges --pretty=format:"%Cred%h%Creset %ad %Cgreen%ae%Creset%n    %s" --since="2020-07-01" $*
}
Glm() {
	git log --date=format:'%Y%m%d_%H%M%S'             --pretty=format:"%Cred%h%Creset %ad %Cgreen%ae%Creset%n    %s" --since="2020-07-01" $*
}

QGitST() {
	GitPRJ="
		kernel/msm-4.14
		device/qcom/sm6150
		device/qcom/qssi
		bootable/bootloader/edk2
		vendor/qcom/proprietary
		system/core
		system/sepolicy
		device/qcom/sepolicy
	"

	Gst ${GitPRJ}
}

ExecTime() {
	BeginTime=`date +%s`
	$*
	EndTime=`date +%s`
	CostTime=`date -d@$((EndTime-BeginTime)) -u +%H:%M:%S`
	echo " --=== Cost time: $CostTime ===--"
}

TopMem() {
	ExeCmd ps -eo pid,cmd,%mem,%cpu --sort=-%mem | head -$1
}
TopCpu() {
	ExeCmd ps -eo pid,cmd,%mem,%cpu --sort=-%cpu | head -$1
}

CppChk() {
	ExeCmd cppcheck --enable=all --inconclusive --std=posix $*
}

CppXChk() {
	ExeCmd cppcheck --enable=all --xml --xml-version=2 $*
}

RepoSync() {
	ExeCmd repo sync -cdq --no-tags --no-repo-verify --no-clone-bundle --jobs=2 --force-sync $*
}

DiskUsage() {
	ExeCmd du -h --max-depth=1 $*
}
