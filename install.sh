#!/bin/bash
ThisDir=`pwd`

# ==== Add Initial.sh in .bashrc ====
InitName="$ThisDir/Initial.sh"
if grep -q $InitName ~/.bashrc ; then
	echo "Setting of $InitName was in ~/.bashrc"
else
	echo "Add Setting of $InitName in ~/.bashrc... "
	echo "source $InitName" >> ~/.bashrc
fi

# ==== Add z.sh for quick access path ====
if [ -d "z" ]; then
	echo "z.sh has already installed, sync it."
	cd z ; git pull
else
	git clone https://github.com/rupa/z
	echo "source $ThisDir/z/z.sh" >> ~/.bashrc
fi

# ==== Sync the Global gitconfig setting ====
echo
echo ========
echo ${COL_YLW}"Check the Global gitconfig is linked"${COL_NON}", command:"
echo ${COL_GRN}"ln -s $ThisDir/GlobalGitConfig ~/.gitconfig"${COL_NON}

# ==== Add local git config for GitHub,  in .get/config ====
echo
echo ========
echo ${COL_YLW}"Add local git config for GitHub"${COL_NON}", in .get/config"
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
