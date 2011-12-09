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
		Exit "Exit to the shell" 2>"${INPUT}"
	if [ $? == 1 ]; then clear && exit 0; fi
	
	menuitem=$(<"${INPUT}")
	
	case $menuitem in
		Controller)
			export NEWHOSTNAME=Cloud-Controller	
			askAllQuestions
		;;
	esac
}


askAllQuestions () {
	if [ ! "$CLOUD_DBPASSWORD" ]; then askForValue "Database Password"; export CLOUD_DBPASSWORD=$(<"${INPUT}"); fi;
        if [ ! "$CLOUD_MYIP" ]; then askForValue "Whats the Management IP of this Server?"; export CLOUD_MYIP=$(<"${INPUT}"); fi;


	echo $CLOUD_DBPASSWORD
}

askForValue () {
	$DIALOG --backtitle "$MENUBACKTITLE" --title "[ Question ]" \
	--inputbox "$1" 10 40 2>"${INPUT}"
}

runAction () {
       	echo -e "Running command $1" > $OUTPUT 
	echo -e "############################################################\n" >> $OUTPUT
	dialog --infobox "Processing, please wait..." 3 34; sudo $1 >> "${OUTPUT}" 2>&1
	dialog --backtitle "$BACK" --title "Action Result" \
                --textbox $OUTPUT 40 70
}

