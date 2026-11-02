#!/bin/bash

ListPkg() {
	sudo apt list --installed > /mnt/nfs/Share/ToAken/PKGs.${HOSTNAME##*-}
}

KeepNewNFiles() {
	if test $# -eq 0 ; then
		echo "USAGE: $0 <<Numbers of files to keep>>"
		return 1
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
		return 1
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

# Show git status of each given path, Param1..N: git project paths
Gst() {
	for EachGit in "$@" ; do
		if [ -d "${EachGit}" ]; then
			echo " $COL_YLW====>$COL_NON Checking git:$COL_LAK $EachGit $COL_NON"
			git -C "$EachGit" status --short
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

	grep -n -v "object directory" $LogName \
		| grep -v 'Following validations failed for the image' \
		| grep -v 'Image operation has not been enabled' \
		| grep -v 'Image operation failed for image' \
		| grep -v 'python command returned error' \
		| grep -v 'Traceback (most recent call last)'  \
		| grep -v " Could not read" \
		| grep -v " TEMP_FAILURE_RETRY" \
		| grep -v " DEBUG_PRINT" \
		| grep -v "liberror" \
		| grep -v "thiserror" \
		| grep \
			-e " error:" \
			-e " ERROR:" \
			-e FAIL \
			-e "syntax error" \
			-e "ISO C90 forbids" \
			-e "forbidden warning" \
			-e "neverallow on line" \
			-e "neverallow check failed" \
			-e "ERROR 'unknown type" \
			-e "dtbo: ERROR" \
			-e "No space left on device" \
			-e 'out/\.lock'
}

# git lg / git lgm are defined in GlobalGitConfig
Glg() {
	git lg "$@"
}
Glm() {
	git lgm "$@"
}

ExecTime() {
	local StartSec=`date +%s.%N`
	"$@"
	echo " --=== Cost time: $(CaculateDuration $StartSec) ===--"
}

TopMem() {
	ExeCmd ps -eo pid,cmd,%mem,%cpu --sort=-%mem | head -${1:-10}
}
TopCpu() {
	ExeCmd ps -eo pid,cmd,%mem,%cpu --sort=-%cpu | head -${1:-10}
}

CppChk() {
	ExeCmd cppcheck --enable=all --inconclusive --std=posix $*
}

CppXChk() {
	ExeCmd cppcheck --enable=all --xml --xml-version=2 $*
}

RepoSync() {
	local StartSec=`date +%s.%N`
	ExeCmd repo sync $REPO_SYNC_OPTS --force-sync $*
	echo "$COL_PUP ==== Total costs: $(CaculateDuration $StartSec) Sec.$COL_NON"
}

DiskUsage() {
	ExeCmd du -h --max-depth=1 $*
}
