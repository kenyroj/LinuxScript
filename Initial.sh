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
# export PS1='\[\e[38;5;135m\]\h\[\e[0m\]:\[\e[38;5;166m\]\w\[\e[0m[\[\e[38;5;118m\]\A\[\e[0m\]]\$ '
export PS1="${COLOR_LAK}\h${COLOR_NON}:${COLOR_GRN}\w${COLOR_NON}[${COLOR_RED}\A${COLOR_NON}] "

#PS1="\[\e]0;\u@\h\a\]$PS1" # Change the putty title

function ExeCmd() {
	CMD=$*
	echo ${COLOR_YLW}" ==>" ${COLOR_GRN}${CMD}${COLOR_NON}
	${CMD}
}