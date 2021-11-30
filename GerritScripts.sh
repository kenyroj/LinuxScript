InitGerrit() {
	export GerritHost=`grep gerrit01 ~/.gitconfig | grep http | cut -d ':' -f 2 | tr -d '/'`
	export GerritUser=`grep email ~/.gitconfig | cut -d '=' -f 2 | cut -d '@' -f 1`
	echo "==== Your ID: $GerritUser @ $GerritHost"
}

GrtPushBranch() {
	InitGerrit
	export DST=$1
	repo forall -c 'echo ; \
		echo [`date +"%m%d-%H%M%S"`] Handle Project: $REPO_PROJECT ; \
		git diff HEAD origin/$DST --exit-code --quiet ; \
		if [ "$?" = "0" ] ; then \
			echo " ---- Repository is the same ----" \
		; else \
			echo " **** Repository was changed!! ****" ; \
			gitdir=$(git rev-parse --git-dir); scp -p -P 29418 $GerritUser@mdt-gerrit01.mic.com.tw:hooks/commit-msg ${gitdir}/hooks/ ; \
			git commit --amend --no-edit ; \
			git push origin HEAD:refs/heads/$DST ; \
		fi '
}

GrtMergeBranch() {
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
	InitGerrit
	export SRC=$1
	export DST=$2
	echo "SRC=$SRC, DST=$DST"

	ExeCmd repo init -u gerrit://main.mdt/manifest.git -b $SRC --reference=/mnt/nfs/QCS610AndroidMirror
	ExeCmd repo sync -cdq --no-tags --no-repo-verify --no-clone-bundle --jobs=2

	repo forall -c 'echo [`date +"%m%d-%H%M%S"`] create $DST branch for $REPO_PROJECT; \
		ssh -p 29418 $GerritUser@$GerritHost gerrit create-branch $REPO_PROJECT $DST $SRC'
}

GrtDeleteBranch() {
	InitGerrit
	export DST=$1
	echo "DST=$DST"

	repo forall -c 'echo [`date +"%m%d-%H%M%S"`] Delete $DST branch for $REPO_PROJECT;\
		git push origin --delete $DST'
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

