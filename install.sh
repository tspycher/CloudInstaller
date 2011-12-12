#!/bin/bash
source init.mod.sh
source roles.mod.sh
source menu.mod.sh

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
	while [ true ];
	do	
		roleSelection
	done
else 
	echo -e "Running Task: $1"
	$1
fi

source cleanup.mod.sh
