#!/bin/bash

# ==== Add Initial.sh in .bashrc ====
InitName="$PWD/Initial.sh"
if grep -q $InitName ~/.bashrc ; then
	echo "Setting of $InitName was in ~/.bashrc"
else
	echo "Add Setting of $InitName in ~/.bashrc... "
	echo "source $InitName" >> ~/.bashrc
fi

# ==== Sync the Global gitconfig setting ====
echo
echo ========
echo ${COL_YLW}"Check the Global gitconfig is linked"${COL_NON}", command:"
echo ${COL_GRN}"ln -s $PWD/GlobalGitConfig ~/.gitconfig"${COL_NON}

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
echo ${COL_GRN}"ln -s $PWD/TmuxConfig ~/.tmux.conf"${COL_NON}
