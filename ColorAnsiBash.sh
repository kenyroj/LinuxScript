#!/bin/bash

export COL_NON='\033[m'
export COL_GRY='\033[1;30m'
export COL_RED='\033[1;31m'
export COL_GRN='\033[1;32m'
export COL_YLW='\033[1;33m'
export COL_BLU='\033[1;34m'
export COL_PUP='\033[1;35m'
export COL_LAK='\033[1;36m'
export COL_WHT='\033[1;37m'

export PSC_NON='\[\e[m\]'
export PSC_GRY='\[\e[1;30m\]'
export PSC_RED='\[\e[1;31m\]'
export PSC_YLW='\[\e[1;33m\]'
export PSC_BLU='\[\e[1;34m\]'
export PSC_GRN='\[\e[1;32m\]'
export PSC_PUP='\[\e[1;35m\]'
export PSC_LAK='\[\e[1;36m\]'
export PSC_WHT='\[\e[1;37m\]'


function COL_RGB() {
	local RGB="$1"
	echo -e "\033[38;5;${RGB}m"
}
function PSC_RGB() {
	local RGB="$1"
	echo "\[\e[38;5;${RGB}m\]"
}
