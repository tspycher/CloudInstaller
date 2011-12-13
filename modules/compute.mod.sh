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
     case $CLOUD_VIRTUALISATION in
    	kvm)
    	    installComputeKVM
    	;;
    	qemu)
    		installComputeQEMU
    	;;	
	esac
	
    apt-get -y install mysql-client-core-5.1 | grep "Setting up"
	apt-get -y install vlan | grep "Setting up"
	apt-get -y install open-iscsi | grep "Setting up"
	apt-get -y install nfs-common | grep "Setting up"
	apt-get -y install kvm | grep "Setting up"
	apt-get -y install iptables | grep "Setting up"
	apt-get -y install ebtables | grep "Setting up"
	apt-get -y install user-mode-linux | grep "Setting up"
	apt-get -y install libvirt-bin | grep "Setting up"
	apt-get -y install python-libvirt | grep "Setting up"
	sed -i '{:q;N;s/\tpost-up[^][^]*.\n//g;t q}' /etc/network/interfaces
	sed -i 's/inet static/inet static\n\tpost-up ifconfig eth1 0.0.0.0/g' /etc/network/interfaces
	sed -i 's/inet dhcp/inet dhcp\n\tpost-up ifconfig eth1 0.0.0.0/g' /etc/network/interfaces
	ifconfig eth1 0.0.0.0

    touch /etc/nova/nova-compute.conf
    rm /etc/nova/nova.conf
    ln -s /etc/nova/nova-compute.conf /etc/nova/nova.conf
   
    echo --iscsi_ip_prefix=$CLOUD_CONTROLLERIP > /etc/nova/nova-compute.conf
	echo --libvirt_use_virtio_for_bridges=false >> /etc/nova/nova-compute.conf
	echo --verbose >> /etc/nova/nova-compute.conf
	echo --rabbit_host=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
	echo --my_ip=$CLOUD_MYIP >> /etc/nova/nova-compute.conf
	echo --num_targets=100 >> /etc/nova/nova-compute.conf
	echo --sql_connection=mysql://root:$CLOUD_DBPASSWORD@$CLOUD_CONTROLLERIP:3306/nova >> /etc/nova/nova-compute.conf
	echo --vncproxy_url=http://$CLOUD_CONTROLLERIP:6080 >> /etc/nova/nova-compute.conf
	echo --lock_path=/tmp >> /etc/nova/nova-compute.conf
	echo --state_path=/var/lib/nova >> /etc/nova/nova-compute.conf
	echo --glance_api_servers=$CLOUD_CONTROLLERIP:9292 >> /etc/nova/nova-compute.conf
	echo --auth_driver=nova.auth.dbdriver.DbDriver >> /etc/nova/nova-compute.conf
	echo --vncserver_host=$CLOUD_MYIP >> /etc/nova/nova-compute.conf
	echo --image_service=nova.image.glance.GlanceImageService >> /etc/nova/nova-compute.conf
	echo --libvirt_type=$CLOUD_VIRTUALISATION >> /etc/nova/nova-compute.conf #qemu,kvm 
	echo --instances_path=/var/lib/nova/instances >> /etc/nova/nova-compute.conf
	echo --logdir=/var/log/nova >> /etc/nova/nova-compute.conf
	echo --resume_guests_state_on_host_boot >> /etc/nova/nova-compute.conf
	echo --use_project_ca >> /etc/nova/nova-compute.conf
	echo --nodaemon >> /etc/nova/nova-compute.conf
	echo --start_guests_on_host_boot=true >> /etc/nova/nova-compute.conf
    
    chown -R root:nova /etc/nova
    chmod 640 /etc/nova/nova.conf
    
    stop libvirt-bin; start libvirt-bin
	stop nova-compute; start nova-compute
	
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