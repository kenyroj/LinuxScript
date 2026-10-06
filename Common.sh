#!/bin/bash
# Common helpers shared by Initial.sh (interactive shell) and standalone/cron scripts.

source "$( dirname "${BASH_SOURCE[0]}" )/ColorAnsiBash.sh"

REPO_SYNC_OPTS="-cdq --no-tags --no-repo-verify --no-clone-bundle --jobs=2"

# Timestamp used in log lines
Ts() {
	date +"%m%d-%H%M%S"
}

# Print the command and run it
ExeCmd() {
	echo -e "${COL_GRN} ==> ${COL_YLW}$*${COL_NON}"
	"$@"
}

# Param1: StartSec (from `date +%s.%N`), prints MM:SS.ss
CaculateDuration() {
	local StartSec=$1
	local EndSec=`date +%s.%N`
	local ElapsedSec=$(echo "$EndSec - $StartSec" | bc)
	local BuildMin=$(echo "$ElapsedSec / 60" | bc)
	local BuildSec=$(echo "$ElapsedSec % 60" | bc)
	printf "%02d:%05.2f" $BuildMin $BuildSec
}
