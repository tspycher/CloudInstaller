MENUBACKTITLE="Cloud Installer - https://github.com/tspycher/CloudInstaller"

roleSelection () {
	$DIALOG --backtitle "$MENUBACKTITLE" \
		--title "[ Role Selection ]" \
		--menu "Please select one of the following roles" 20 80 12 \
		Controller "Install an controller (MySQL,Rabbit,Compute,Keystone,Horizon)" \
		Network "Install Network components" \
		Volume "Install Volume components" \
		FirstImage "Download and publish an Ubuntu 10.04 Image" \
		Compute-KVM "Configure a Compute Endpoint based on KVM" \
		Preset "Set all Values" \
		Values "Show all Values" \
		Verify "Verify your installation" \
		Exit "Exit to the shell" 2>"${INPUT}"
	if [ $? == 1 ]; then clear && exit 0; fi
	
	menuitem=$(<"${INPUT}")
	
	case $menuitem in
		Controller)
            if [ ! "$CLOUD_NEWHOSTNAME" ]; then export CLOUD_NEWHOSTNAME="Cloud-Controller"; fi;
			askAllQuestions
			runAction controller
		;;
		Network)
			askAllQuestions
			runAction network
		;;
		Volume)
			selectDisk	
			askAllQuestions
			runAction volume
		;;
		FirstImage)
			askAllQuestions
            runAction "installFirstImage"
		;;
		Compute-KVM)
            if [ ! "$CLOUD_CONTROLLERIP" ]; then askForValue "IP of the Controller"; export CLOUD_CONTROLLERIP=$(<"${INPUT}"); fi;
            if [ ! "$CLOUD_COMPUTENUMBER" ]; then askForValue "Identifier for this Compute Node"; export CLOUD_COMPUTENUMBER=$(<"${INPUT}"); fi;
            if [ ! "$CLOUD_NEWHOSTNAME" ]; then export CLOUD_NEWHOSTNAME="Cloud-Compute$CLOUD_COMPUTENUMBER"; fi;
			if [ ! "$CLOUD_VIRTUALISATION" ]; then
				$DIALOG --backtitle "$MENUBACKTITLE" \
						--title "[ Virtualisation Selection ]" \
						--menu "Select an virtualisation engine" 20 80 12 \
						kvm "Install an controller (MySQL,Rabbit,Compute,Keystone,Horizon)" \
						qemu "Install Network components" 2>"${INPUT}"
				export CLOUD_VIRTUALISATION==$(<"${INPUT}")
			fi
			
			askAllQuestions
			runAction compute	
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
	$DIALOG --backtitle "$MENUBACKTITLE" --title "[ Delete a Repository]" \
	--menu "Select Disk for Volume (will be erased!!!)" 30 40 40 $DISK 2>"${INPUT}"
	disk=$(<"${INPUT}")
	export CLOUD_ISCSIDISK=$disk
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
	$DIALOG --backtitle "$MENUBACKTITLE" --infobox "Processing, please wait..." 3 34; $1 > "${OUTPUT}" 2>&1
	$DIALOG --backtitle "$MENUBACKTITLE" --title "Action Result" \
                --textbox $OUTPUT 40 70
}

