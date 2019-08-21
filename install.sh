#!/bin/bash

InitName="$PWD/Initial.sh"
echo "source $InitName" >> ~/.bashrc

# ==== Sync the gitconfig setting ====
echo ${COLOR_YLW}"Check the Global gitconfig is linked"${COLOR_NON}", command:"
echo ${COLOR_GRN}"ln -s $PWD/GlobalGitConfig ~/.gitconfig"${COLOR_NON}
