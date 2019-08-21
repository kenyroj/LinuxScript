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

function COLOR_RGB() {
	local RGB_R="$1"
	local RGB_G="$2"
	local RGB_B="$3"
	echo R=$RGB_R, G=$RGB_G, B=$RGB_B
	echo "[38;5;208mpeach[0;00m"
	echo "[$(RGB_R);$(RGB_G);$(RGB_B)m peach [0;00m"
}
