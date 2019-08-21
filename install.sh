#!/bin/bash

# ==== Add Initial.sh in .bashrc ====
InitName="$PWD/Initial.sh"
if grep -q $InitName ~/.bashrc ; then
	echo "Setting of $InitName was in ~/.bashrc"
else
	echo "Add Setting of $InitName in ~/.bashrc... "
	echo "source $InitName" >> ~/.bashrc
fi

# ==== Sync the gitconfig setting ====
echo ========
echo ${COLOR_YLW}"Check the Global gitconfig is linked"${COLOR_NON}", command:"
echo ${COLOR_GRN}"ln -s $PWD/GlobalGitConfig ~/.gitconfig"${COLOR_NON}

# ==== Add local git config for GitHub,  in .get/config ====
echo ========
echo ${COLOR_YLW}"Add local git config for GitHub"${COLOR_NON}", in .get/config"
echo ${COLOR_GRN}"[user]"
echo "	name = kenyroj"
echo "	email = kenyroj@gmail.com"
echo "	username = kenyroj"${COLOR_NON}
