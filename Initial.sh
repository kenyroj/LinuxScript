#!/bin/bash

LocalPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $LocalPath/ColorAnsiBash.sh

source $LocalPath/AKenScript.sh

# ==== Alias ====
alias ls='ls --color=auto -F'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ..='cd ..;'

alias tmux='tmux -2'

# ==== For PROMPT ====
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

# Set PROMPT
SHORT_HOST=`echo $HOSTNAME | rev | cut -d '-' -f 1 | rev`
PS_TIME_COLOR=$(PSC_RGB 208)
if [ $UID = 0 ] ; then
	# if user is root, use Red time
	PS_TIME_COLOR=$PSC_RED
elif [ "$USER" = "kenyroj" -o "$USER" = "aken.hsu" ] ; then
	# if user ID is aken.hsu or kenyroj, use Yellow time
	PS_TIME_COLOR=$PSC_YLW
elif [ "$USER" = "mdtuser" ] ; then
	# if user ID is mdtuser, use Purple time
	PS_TIME_COLOR=$PSC_PUP
else
	# Other users, use Blue time
	PS_TIME_COLOR=$PSC_BLU
fi
export PS1='${?/#0/}'"${PSC_LAK}${SHORT_HOST}${PSC_NON}:${PSC_GRN}\w${PSC_NON}[$PS_TIME_COLOR\A${PSC_NON}] "

#PS1="\[\e]0;\u@\h\a\]$PS1" # Change the putty title

function ExeCmd() {
	CMD=$*
	echo ${COL_GRN}" ==>" ${COL_YLW}${CMD}${COL_NON}
	${CMD}
}

# For android build ccache
#export USE_CCACHE=1
#export CCACHE_DIR=/mnt/nfs/CCache

