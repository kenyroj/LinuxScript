#!/bin/bash

export COLOR_NON='[0m'
export COLOR_GRY='[1;30m'
export COLOR_RED='[1;31m'
export COLOR_GRN='[1;32m'
export COLOR_YLW='[1;33m'
export COLOR_BLU='[1;34m'
export COLOR_PUP='[1;35m'
export COLOR_LAK='[1;36m'
export COLOR_WHT='[1;37m'

# Alias
alias ls='ls --color=auto -F'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ..='cd ..;'

function CollapsedPWD() {
	local pwd="$1"
	local home="$HOME"
	local size=${#home}
	[[ $# == 0 ]] && pwd="$PWD"
	[[ -z "$pwd" ]] && return
	if [[ "$pwd" == "/" ]]; then
		echo "/"
		return
	elif [[ "$pwd" == "$home" ]]; then
		echo "~"
		return
	fi
	[[ "$pwd" == "$home/"* ]] && pwd="~${pwd:$size}"
	if [[ -n "$BASH_VERSION" ]]; then
		local IFS="/"
		local elements=($pwd)
		local length=${#elements[@]}
		for ((i=0;i<length-1;i++)); do
			local elem=${elements[$i]}
			if [[ ${#elem} -gt 1 ]]; then
				elements[$i]=${elem:0:1}
			fi
		done
	else
		local elements=("${(s:/:)pwd}")
		local length=${#elements}
		for i in {1..$((length-1))}; do
			local elem=${elements[$i]}
			if [[ ${#elem} > 1 ]]; then
				elements[$i]=${elem[1]}
			fi
		done
	fi
	local IFS="/"
	echo "${elements[*]}"
}

# For PROMPT
# export PS1='\[\e[38;5;135m\]\h\[\e[0m\]:\[\e[38;5;166m\]\w\[\e[0m[\[\e[38;5;118m\]\A\[\e[0m\]]\$ '
export PS1="${COLOR_LAK}\h${COLOR_NON}:${COLOR_GRN}\w${COLOR_NON}[${COLOR_RED}\A${COLOR_NON}]"

#PS1="\[\e]0;\u@\h\a\]$PS1" # Change the putty title

function ExeCmd() {
	CMD=$*
	echo ${COLOR_YLW}" ==>" ${COLOR_GRN}${CMD}${COLOR_NON}
	${CMD}
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


