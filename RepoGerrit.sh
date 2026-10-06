#!/bin/bash
# Push all heads and tags of current git project to another Gerrit host.
# Usage (run in repo root): repo forall -c 'bash ~/script/RepoGerrit.sh <GerritHost>'
# Param1: Gerrit host

GERRIT_HOST=$1

echo
echo [`date +"%y%m%d-%H%M%S"`] Gerrit Host:$GERRIT_HOST, Push refs/heads/* and refs/tags/* of $REPO_PROJECT
git push ssh://aken.hsu@$GERRIT_HOST:29418/$REPO_PROJECT 'refs/heads/*' 'refs/tags/*'
