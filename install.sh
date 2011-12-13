#!/bin/bash
source init.mod.sh
source roles.mod.sh
source menu.mod.sh

if [ ! -n "$1" ]; then
	while [ true ];
	do	
		roleSelection
	done
else 
	askAllQuestions
	echo -e "Running Task: $1"
	$1
fi

source cleanup.mod.sh
