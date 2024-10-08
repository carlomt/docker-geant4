#!/bin/bash
cat /etc/lsb-release

# gcc
source /opt/rh/devtoolset-9/enable

# Geant4
source  /opt/geant4/bin/geant4.sh

export HISTCONTROL=ignoredups

alias cd..='cd ..'
alias ls='ls -GF'
alias ll='ls -ltrh'

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
/opt/geant4/bin/geant4-config --check-datasets
echo " "
echo "To keep the size of the Docker images limited, the Geant4 datasets are not installed."
echo "They are expect to be found in /opt/geant4/data"
echo "I suggest you to map a folder in the host to use always the same dataset with the option:"
echo "--volume=\'HOST_PATH/geant4-data:/opt/geant4/data:ro\' "
echo "If some, or all, are missing it is possible to install the datasets from the docker with:"
echo "geant4-config --install-datasets"
echo "in this case, if you want to dowload the datasets in a host folder,"
echo "you must mount the volume without the read-only flag:"
echo "--volume=\'HOST_PATH/geant4-data:/opt/geant4/data\' "
echo "#############################################################################################"
echo " "
echo "## Geant4 examples ##########################################################################"
echo "To save space, Geant4 examples have been removed, to download them:"
echo "curl https://gitlab.cern.ch/geant4/geant4/-/archive/geant4-`/opt/geant4/bin/geant4-config --version | awk -F '.' '{print $1"."$2}'`-release/geant4-master.tar.gz?path=examples --output examples.tar.gz && tar xf examples.tar.gz --strip-components 1"
echo " "

# Execute the command passed to the Docker container
exec "$@"
