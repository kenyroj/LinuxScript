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
	GitLog=`git lgm HEAD ^origin/$BranchName` ; \
	if [ ! -z "$GitLog" ] ; then \
		echo " ==== Git LOG of $REPO_PROJECT:" ; echo "$GitLog" ; echo ;\
	fi \
'
}

GrtStatus() {
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
		if git fetch -q ssh://$GerritUser@$GerritHost:29418/$REPO_PROJECT refs/heads/$DST 2>/dev/null \
			&& git diff HEAD FETCH_HEAD --exit-code --quiet ; then \
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
		' 2>&1 | tee "Merge_${SRC}_to_${DST}_${CodeNote}.log"


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
		git checkout -b $SRC ; \
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

# Run a command on the Gerrit server through ssh
GrtSsh() {
	ssh -p 29418 ${GerritUser}@${GerritHost} "$@"
}

CmdGerrit() {
	InitGerrit
	ExeCmd GrtSsh gerrit "$@"
}

PushHeadTagByGit() {
	if [ -z "$1" ] ; then
		echo "Usage: Param1: Project name on Gerrit"
		return 1
	fi

	InitGerrit
	local PROJ_NAME=$1
	echo [`Ts`] Push heads and tags of $PROJ_NAME
	ExeCmd git push ssh://${GerritUser}@${GerritHost}:29418/${PROJ_NAME} 'refs/heads/*' 'refs/tags/*'
}

GrtDelRepo() {
	if [ $# -eq 0 ] ; then
		echo "Usage: Param1..N: Project names on Gerrit to DELETE"
		return 1
	fi

	InitGerrit
	local Answer
	read -p "Really delete $* on $GerritHost? [y/N] " Answer
	[ "$Answer" = "y" -o "$Answer" = "Y" ] || return 1

	for EachGit in "$@" ; do
		echo [`Ts`] Delete Repository: $EachGit
		ExeCmd GrtSsh delete-project delete --yes-really-delete $EachGit
	done
}

CreateRepo() {
	if [ -z "$1" ] ; then
		echo "Usage: Param1: Project name to create on Gerrit"
		return 1
	fi

	InitGerrit
	local REPO_PROJECT=$1
	local OWNER=MDT_Member
	local PARENT_PRJ=MDT_Project
	echo [`Ts`] Create Project and Set Owner: $REPO_PROJECT
	GrtSsh gerrit create-project --owner $OWNER $REPO_PROJECT
	echo [`Ts`] Set Parent Project: $REPO_PROJECT
	GrtSsh gerrit set-project-parent --parent $PARENT_PRJ $REPO_PROJECT
}

NewBranch() {
	if [ -z "$2" ] ; then
		echo "Usage: Param1: Project name on Gerrit"
		echo "Usage: Param2: New BranchName"
		echo "Usage: Param3: From BranchName (default: master)"
		return 1
	fi

	InitGerrit
	local REPO_PROJECT=$1
	local BRANCH_NAME=$2
	local FROM_BRANCH=${3:-master}
	echo [`Ts`] New branch on Repository: $BRANCH_NAME - $REPO_PROJECT
	GrtSsh gerrit create-branch $REPO_PROJECT $BRANCH_NAME $FROM_BRANCH
}
