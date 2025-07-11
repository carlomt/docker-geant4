#!/bin/bash
cat /etc/lsb-release

export HISTCONTROL=ignoredups

alias cd..='cd ..'
alias ls='ls -GF'
alias ll='ls -ltrh'

# Only load Liquidprompt in interactive shells, not from a script or from scp
#[[ $- = *i* ]] && source /opt/liquidprompt/liquidprompt

# CMake
#export PATH=/opt/cmake/bin/:$PATH

# Geant4
source  /usr/local/bin/geant4.sh

echo " "
echo "## Compiler version ##############################################################################"
$CC --version
echo " "
echo "## CMake version ############################################################################"
cmake --version
echo " "
echo "## Geant4 version ###########################################################################"
geant4-config --version
echo " "
echo "## checking Geant4 datasets #################################################################"
geant4-config --check-datasets
echo " "
echo "To keep the size of the Docker images limited, the Geant4 datasets are not installed."
echo "They are expect to be found in /g4data"
echo "I suggest you to map a folder in the host to use always the same dataset with the option:"
echo "--volume=\'HOST_PATH/geant4-data:/g4data:ro\' "
echo "If some, or all, are missing it is possible to install the datasets from the docker with:"
echo "geant4-config --install-datasets"
echo "in this case, if you want to dowload the datasets in a host folder,"
echo "you must mount the volume without the read-only flag:"
echo "--volume=\'HOST_PATH/geant4-data:/g4data\' "
echo "#############################################################################################"
echo " "
echo "## Geant4 examples ##########################################################################"
echo "To save space, Geant4 examples have been removed, to download them:"
echo "curl https://gitlab.cern.ch/geant4/geant4/-/archive/geant4-`geant4-config --version | awk -F '.' '{print $1"."$2}'`-release/geant4-master.tar.gz?path=examples --output examples.tar.gz && tar xf examples.tar.gz --strip-components 1"
echo " "

# Execute the command passed to the Docker container
exec "$@"
