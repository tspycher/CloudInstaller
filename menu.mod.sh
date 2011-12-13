MENUBACKTITLE="Cloud Installer - https://github.com/tspycher/CloudInstaller"

roleSelection () {
	$DIALOG --backtitle "$MENUBACKTITLE" \
		--title "[ Role Selection ]" \
		--menu "Please select one of the following roles" 20 80 12 \
		Controller "Install an controller (MySQL,Rabbit,Compute,Keystone,Horizon)" \
		#Network "Install Network components" \
		#Volume "Install Volume components" \
		Horizon "Install Horizon only" \
		Keystone "Install Keystone only" \
		FirstImage "Download and publish an Ubuntu 10.04 Image" \
		ComputeRun "Configure a Compute Endpoint" \
		Preset "Set all Values" \
		Values "Show all Values" \
		Verify "Verify your installation" \
		StartHorizon "Start Horizon DevServer" \
		Exit "Exit to the shell" 2>"${INPUT}"
	if [ $? == 1 ]; then clear && exit 0; fi
	
	menuitem=$(<"${INPUT}")
	
	case $menuitem in
		Controller)
            if [ ! "$CLOUD_NEWHOSTNAME" ]; then export CLOUD_NEWHOSTNAME="Cloud-Controller"; fi;
			askAllQuestions
			runAction controller "Installing Controller Node. This will take some minutes..."
		;;
		Horizon)
			askAllQuestions
			runAction horizonOnly "Install only Horzon"
		;;
		Keystone)
			askAllQuestions
		    runAction keystoneOnly "Install only Keystone"
		;;
		Network)
			askAllQuestions
			runAction network "Installing Network Components"
		;;
		Volume)
			selectDisk	
			askAllQuestions
			runAction volume "Installing Volume Components"
		;;
		FirstImage)
			askAllQuestions
            runAction installImage "Installing The First Image"
		;;
		ComputeRun)
            if [ ! "$CLOUD_CONTROLLERIP" ]; then askForValue "IP of the Controller"; export CLOUD_CONTROLLERIP=$(<"${INPUT}"); fi;
            if [ ! "$CLOUD_COMPUTENUMBER" ]; then askForValue "Identifier for this Compute Node"; export CLOUD_COMPUTENUMBER=$(<"${INPUT}"); fi;
            if [ ! "$CLOUD_NEWHOSTNAME" ]; then export CLOUD_NEWHOSTNAME="Cloud-Compute$CLOUD_COMPUTENUMBER"; fi;
			
			checkVirtualisation
			if [ ! "$CLOUD_VIRTUALISATION" ]; then
				$DIALOG --backtitle "$MENUBACKTITLE" \
						--title "[ Virtualisation Selection ]" \
						--menu "Select an virtualisation engine" 20 80 12 \
						kvm "Install an controller (MySQL,Rabbit,Compute,Keystone,Horizon)" \
						qemu "Install Network components" 2>"${INPUT}"
				export CLOUD_VIRTUALISATION==$(<"${INPUT}")
			fi
			
			askAllQuestions
			runAction compute "Installing Compute node for $CLOUD_VIRTUALISATION virtualisation"
		;;
		Preset)
			askAllQuestions
		;;
		Values)
			showAllAnswers	
		;;
		Verify)
		    if [ ! "$CLOUD_ADMINTOKEN" ]; then askForValue "Define the Admin Token"; export CLOUD_ADMINTOKEN=$(<"${INPUT}"); fi;
			runAction verify
		;;
		StartHorizon)
			startHorizonDev
		;;
		Exit)
			exit	
		;;
	esac
}

askAllQuestions () {
	if [ ! "$CLOUD_DBPASSWORD" ]; then askForValue "Database Password"; export CLOUD_DBPASSWORD=$(<"${INPUT}"); fi;
    if [ ! "$CLOUD_MYIP" ]; then askForValue "Whats the Management IP of this Server?"; export CLOUD_MYIP=$(<"${INPUT}"); fi;
    if [ ! "$CLOUD_ADMINTOKEN" ]; then askForValue "Define the Admin Token"; export CLOUD_ADMINTOKEN=$(<"${INPUT}"); fi;
}

selectDisk () {
	DISK=`sudo ls -1 /dev | grep sd | awk '{print $1" "$1}'`
	if [ ! "$CLOUD_ISCSIDISK" ]; then
		$DIALOG --backtitle "$MENUBACKTITLE" --title "[ Delete a Repository]" \
		--menu "Select Disk for Volume (will be erased!!!)" 30 40 40 $DISK 2>"${INPUT}"
		disk=$(<"${INPUT}")
		export CLOUD_ISCSIDISK=$disk
	fi
}

showAllAnswers () {
	data=`env | grep -i CLOUD_`
	runAction 'echo -e "'$data'"'
}

askForValue () {
	$DIALOG --backtitle "$MENUBACKTITLE" --title "[ Question ]" \
	--inputbox "$1" 10 40 2>"${INPUT}"
}

runAction () {
	if [ "$2" ]; then messageBox "$2"; fi;
	
	$DIALOG --backtitle "$MENUBACKTITLE" --infobox "Processing, please wait..." 3 34; $1 > "${OUTPUT}" 2>&1
	$DIALOG --backtitle "$MENUBACKTITLE" --title "Action Result" \
                --textbox $OUTPUT 40 70
}

messageBox () {
	$DIALOG --backtitle "$MENUBACKTITLE" --msgbox "$1" 7 80	
}

