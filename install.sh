#!/bin/bash
ThisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$ThisDir"
source "$ThisDir/ColorAnsiBash.sh"

# ==== Add Initial.sh in .bashrc ====
InitName="$ThisDir/Initial.sh"
if grep -qF "$InitName" ~/.bashrc ; then
	echo "Setting of $InitName was in ~/.bashrc"
else
	echo "Add Setting of $InitName in ~/.bashrc... "
	echo "source $InitName" >> ~/.bashrc
fi

# ==== Add z.sh for quick access path ====
if [ -d "z" ]; then
	echo "z.sh has already installed, sync it."
	git -C z pull
else
	if git clone https://github.com/rupa/z ; then
		echo "source $ThisDir/z/z.sh" >> ~/.bashrc
	fi
fi

# ==== Sync the Global gitconfig setting ====
echo
echo ========
echo ${COL_YLW}"Check the Global gitconfig is linked"${COL_NON}", command:"
echo ${COL_GRN}"ln -s $ThisDir/GlobalGitConfig ~/.gitconfig"${COL_NON}

# ==== Add local git config for GitHub,  in .git/config ====
echo
echo ========
echo ${COL_YLW}"Add local git config for GitHub"${COL_NON}", in .git/config"
echo ${COL_GRN}"[user]"
echo "	name = kenyroj"
echo "	email = kenyroj@gmail.com"
echo "	username = kenyroj"${COL_NON}

# ==== Sync the Tmux setting ====
echo
echo ========
echo ${COL_YLW}"Check the tmux setting is linked"${COL_NON}", command:"
echo ${COL_GRN}"ln -s $ThisDir/TmuxConfig ~/.tmux.conf"${COL_NON}

# ==== Sync the vimrc setting ====
echo
echo ========
echo ${COL_YLW}"Check the vimrc setting is linked"${COL_NON}", command:"
echo ${COL_GRN}"ln -s $ThisDir/VimRC ~/.vimrc"${COL_NON}
