#!/bin/bash

################################################################################
## Hongkee Yoon Hongkeeyoon@kaist.ac.kr
## 2019.05
## https://github.com/KAIST-ELST/Jx.jl
## https://github.com/KAIST-ELST/DFTforge.jl
################################################################################

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo 'This is Jx installer. If Julia is already installed simply type julia install.jl'
printf "${BLUE} Jx is tested for julia 1.0 & 1.1 (the most recent verion of julia in 201905) ${NC} \n"
printf "${BLUE} Visit https://kaist-elst.github.io/DFTforge.jl/ for details and updates ${NC} \n"

echo ' To install julia see: https://julialang.org/downloads/'
echo ' Platform specfic detail see: https://julialang.org/downloads/platform.html'
echo '========================================================================='
printf "${RED} Please install hdf5 lib before the install (e.g. in Ubuntu 'apt-get install hdf5-tools', OSX 'brew install hdf5') ${NC} \n"
echo '========================================================================='

printf "${BLUE} 1. Installing the  Julia ${NC} \n"
sleep 2
case "$OSTYPE" in
  #solaris*) echo "SOLARIS" ;;
  darwin*)  echo "OSX"
  brew cask install juliaup
  brew cask upgrade juliaup
  ;;
  linux*)
  echo "Linux"
  #mkdir -p ~/bin
  #echo 'export PATH=~/bin:$PATH' >>~/.profile
  #echo 'export PATH=~/bin:$PATH' >>~/.bashrc
  #JULIA_INSTALL=~/bin  bash -ci "$(curl -fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh)"
  curl -fsSL https://install.julialang.org | sh
  ;;
  bsd*)     echo "BSD"
  echo 'Visit https://julialang.org/downloads/'
  ;;
  *)        echo "unknown: $OSTYPE"
  echo 'Visit https://julialang.org/downloads/'
  ;;
esac

echo ' The Julia install would be finished.'

echo ' Now the below commands will be excuted'
printf "${GREEN}source ~/.profile # to detect installed Julia ${NC}\n"
printf "${GREEN}julia install.jl ${NC}\n"

source ~/.profile
printf "${BLUE} 2. Installing required Julia packages & DFTforge.jl ${NC}\n"
sleep 2
julia install.jl

echo '========================================================================='
echo 'If `DFTforge Version XXX` is shown above, the install would completed without error. '
echo 'Try to run NiO example by typing the'
printf "${BLUE}./example_NiO_OpenMX.sh ${NC}\n"
echo '========================================================================='

# install DFTforge
julia install.jl
