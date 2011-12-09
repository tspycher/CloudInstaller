#!/bin/bash
source init.mod.sh
source roles.mod.sh
source menu.mod.sh

# Loading all modules
for file in ./modules/*; do source ${file}; done;

doAll () {
    installBase
    installController
    initDatabase
    installKeystone
    initKeystone
    installHorizon
    restartAll
    installNetworking
    installVolumes
    installFirstImage
}

if [ ! -n "$1" ]; then
	echo "Options are:"
	echo -e "\t installBase"
	echo -e "\t installController"
	echo -e "\t initDatabase"
	echo -e "\t installKeystone"
	echo -e "\t initKeystone"
	echo -e "\t installHorizon"
	echo -e "\t restartAll"
	echo -e "\t installNetworking"
	echo -e "\t installVolumes"
	echo -e "\t installFirstImage"
	echo -e "\t doAll"
	roleSelection
else 
	echo -e "Running Task: $1"
	$1
fi

source cleanup.mod.sh
