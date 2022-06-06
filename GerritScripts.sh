InitGerrit() {
	export GerritHost=`grep gerrit01 ~/.gitconfig | grep http | cut -d ':' -f 2 | tr -d '/'`
	export GerritUser=`grep email ~/.gitconfig | cut -d '=' -f 2 | cut -d '@' -f 1 | tr -d ' '`
	echo "==== Your ID: $GerritUser @ $GerritHost"
}

GrtLog() {
	if [ -z $1 ] ; then
		echo "Usage: Param1: BranchName"
		return 1
	fi

	InitGerrit
	export BranchName=$1

	repo forall -c '\
	GitLog=`git log --date=format:"%Y%m%d_%H%M%S" --pretty=format:"%Cred%h%Creset %ad %Cgreen%ae%Creset%n    %s" HEAD ^origin/$BranchName` ; \
	if [ ! -z "$GitLog" ] ; then \
		echo " ==== Git LOG of $REPO_PROJECT:" ; echo "$GitLog" ; echo ;\
	fi \
'
}

GrtStatus() {
	if [ -z $1 ] ; then
		echo "Usage: Param1: BranchName"
		return 1
	fi

	InitGerrit
	export BranchName=$1

	repo forall -c '\
	GitST=`git status --short` ; \
	if [ ! -z "$GitST" ] ; then \
		echo " ==== Git statis of $REPO_PROJECT:" ; echo "$GitST" ; echo ;\
	fi \
'
}

GrtPushBranch() {
	if [ -z $1 ] ; then
		echo "Usage: Param1: DST BranchName"
		return 1
	fi

	InitGerrit
	export DST=$1
	repo forall -c 'echo ; \
		echo [`date +"%m%d-%H%M%S"`] Handle Project: $REPO_PROJECT ; \
		git diff HEAD ssh://$GerritUser@$GerritHost:29418/$DST --exit-code --quiet ; \
		if [ "$?" = "0" ] ; then \
			echo " ---- Repository is the same ----" \
		; else \
			echo " **** Repository was changed!! ****" ; \
			gitdir=$(git rev-parse --git-dir); scp -p -P 29418 $GerritUser@$GerritHost:hooks/commit-msg ${gitdir}/hooks/ ; \
			git commit --amend --no-edit ; \
			git push -f ssh://$GerritUser@$GerritHost:29418/$REPO_PROJECT HEAD:refs/heads/$DST ; \
		fi '
}

GrtMergeBranch() {
	if [ -z $3 ] ; then
		echo "Usage: Param1: SRC BranchName"
		echo "Usage: Param2: DST BranchName"
		echo "Usage: Param3: CodeNote: FC CS ..."
		return 1
	fi

	InitGerrit
	export SRC=$1
	export DST=$2
	export CodeNote=$3
	echo "SRC=$SRC, DST=$DST, CodeNote=$CodeNote"
	export SRC_HOME="Code_$SRC"

	repo forall -c 'echo ; \
		echo [`date +"%m%d-%H%M%S"`] Fetch Project: $REPO_PROJECT of $SRC ; \
		git fetch origin $SRC'

	repo forall -c 'echo ; \
		echo [`date +"%m%d-%H%M%S"`] Merge Project: $REPO_PROJECT ; \
		git merge --no-ff --log -m "Merge CodeBase $CodeNote into $DST" origin/$SRC \
		' | tee "Merge_$SRC_to_$DST_$CodeNote.log" 2>&1


}

GrtCloneBranch() {
	if [ -z $2 ] ; then
		echo "Usage: Param1: SRC BranchName"
		echo "Usage: Param2: DST BranchName"
		return 1
	fi

	InitGerrit
	export SRC=$1
	export DST=$2
	echo "SRC=$SRC, DST=$DST"

	repo forall -c 'echo [`date +"%m%d-%H%M%S"`] create $DST branch for $REPO_PROJECT; \
		ssh -p 29418 $GerritUser@$GerritHost gerrit create-branch $REPO_PROJECT $DST $SRC'
}

GrtDeleteBranch() {
	if [ -z $1 ] ; then
		echo "Usage: Param1: DST BranchName"
		return 1
	fi

	InitGerrit
	export DST=$1
	echo "DST=$DST"

	repo forall -c 'echo [`date +"%m%d-%H%M%S"`] Delete $DST branch for $REPO_PROJECT;\
		git push ssh://$GerritUser@$GerritHost:29418/$REPO_PROJECT --delete $DST'

}

CmdGerrit() {
	InitGerrit
	Cmd="ssh -p 29418 ${GerritUser}@${GerritHost} gerrit $*"
	ExeCmd $Cmd
}

PushHeadTagByGit() {
	InitGerrit
	PROJ_NAME=$1
	for n in $(git for-each-ref --format='%(refname)' refs/heads) ; do
		echo [`date +"%m%d-%H%M%S"`] - $n @ $PROJ_NAME
		Cmd="git push ssh://${GerritUser}@${GerritHost}:29418/${PROJ_NAME} $n"
		ExeCmd $Cmd
	done
	for n in $(git for-each-ref --format='%(refname)' refs/tags) ; do
		echo [`date +"%m%d-%H%M%S"`] - $n @ $PROJ_NAME
		Cmd="git push ssh://${GerritUser}@${GerritHost}:29418/${PROJ_NAME} $n"
		ExeCmd $Cmd
	done
	echo Push heads and tags of $PROJ_NAME Finished.
}

DelGerritProj() {
	InitGerrit
	for EachGit in $* ; do
		Cmd="ssh -p 29418 ${GerritUser}@${GerritHost} delete-project delete --yes-really-delete $EachGit"
		ExeCmd $Cmd
	done;
}

