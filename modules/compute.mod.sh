checkVirtualisation () {
	if [ -e /usr/sbin/kvm-ok ]; then
		/usr/sbin/kvm-ok
		if [ $? == 0 ]; then
			# We've got KVM Support
			export CLOUD_VIRTUALISATION=kvm
		else
			export CLOUD_VIRTUALISATION=qemu
		fi
	fi	
}

installComputeKVM () {
	echo -e "Steps to install KVM"
	apt-get -y install nova-compute-kvm
}

installComputeQEMU () {
	echo -e "Steps to install QEMU"	
}
	
installCompute () {      
	CONFIGFILE=/etc/nova/nova-compute.conf.cloudinstaller
	
	case $CLOUD_VIRTUALISATION in
    	kvm)
    	    installComputeKVM
    	;;
    	qemu)
    		installComputeQEMU
    	;;	
	esac
	
    apt-get -y install mysql-client-core-5.1 2>/dev/null | grep "Setting up"
	apt-get -y install vlan 2>/dev/null | grep "Setting up"
	apt-get -y install open-iscsi 2>/dev/null | grep "Setting up"
	apt-get -y install nfs-common 2>/dev/null | grep "Setting up"
	apt-get -y install kvm 2>/dev/null | grep "Setting up"
	apt-get -y install iptables 2>/dev/null | grep "Setting up"
	apt-get -y install ebtables 2>/dev/null | grep "Setting up"
	apt-get -y install user-mode-linux 2>/dev/null | grep "Setting up"
	apt-get -y install libvirt-bin 2>/dev/null | grep "Setting up"
	apt-get -y install python-libvirt 2>/dev/null| grep "Setting up"
	sed -i '{:q;N;s/\tpost-up[^][^]*.\n//g;t q}' /etc/network/interfaces
	sed -i 's/inet static/inet static\n\tpost-up ifconfig eth1 0.0.0.0/g' /etc/network/interfaces
	sed -i 's/inet dhcp/inet dhcp\n\tpost-up ifconfig eth1 0.0.0.0/g' /etc/network/interfaces
	ifconfig eth1 0.0.0.0

    #touch $CONFIGFILE
    #rm /etc/nova/nova.conf
    #ln -s $CONFIGFILE /etc/nova/nova.conf
   
    echo --iscsi_ip_prefix=$CLOUD_CONTROLLERIP > $CONFIGFILE
	echo --libvirt_use_virtio_for_bridges=false >> $CONFIGFILE
	echo --verbose >> $CONFIGFILE
	echo --rabbit_host=$CLOUD_CONTROLLERIP >> $CONFIGFILE
	echo --my_ip=$CLOUD_MYIP >> $CONFIGFILE
	echo --num_targets=100 >> $CONFIGFILE
	echo --sql_connection=mysql://root:$CLOUD_DBPASSWORD@$CLOUD_CONTROLLERIP:3306/nova >> $CONFIGFILE
	echo --vncproxy_url=http://$CLOUD_CONTROLLERIP:6080 >> $CONFIGFILE
	echo --lock_path=/tmp >> $CONFIGFILE
	echo --state_path=/var/lib/nova >> $CONFIGFILE
	echo --glance_api_servers=$CLOUD_CONTROLLERIP:9292 >> $CONFIGFILE
	echo --auth_driver=nova.auth.dbdriver.DbDriver >> $CONFIGFILE
	echo --vncserver_host=$CLOUD_MYIP >> $CONFIGFILE
	echo --image_service=nova.image.glance.GlanceImageService >> $CONFIGFILE
	echo --libvirt_type=$CLOUD_VIRTUALISATION >> $CONFIGFILE #qemu,kvm 
	echo --instances_path=/var/lib/nova/instances >> $CONFIGFILE
	echo --logdir=/var/log/nova >> $CONFIGFILE
	echo --resume_guests_state_on_host_boot >> $CONFIGFILE
	echo --use_project_ca >> $CONFIGFILE
	echo --nodaemon >> $CONFIGFILE
	echo --start_guests_on_host_boot=true >> $CONFIGFILE
    
    chown -R root:nova /etc/nova
    chmod 640 /etc/nova/nova.conf
    
    restartAll
	
	case $CLOUD_VIRTUALISATION in
    	kvm)
    	    afterInstallComputeKVM
    	;;
    	qemu)
    		afterInstallComputeQEMU
    	;;	
	esac
}

afterInstallComputeKVM () {
	echo -e "Steps after install KVM"
}

afterInstallComputeQEMU () {
	echo -e "Steps after install QEMU"	
}