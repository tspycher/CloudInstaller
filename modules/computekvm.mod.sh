installComputeKVM () {
    VIRTUALISATION=kvm
    
    apt-get -y install nova-compute-kvm
	apt-get -y install vlan
	apt-get -y install open-iscsi
	apt-get -y install nfs-common
	apt-get -y install kvm
	apt-get -y install iptables
	apt-get -y install ebtables
	apt-get -y install user-mode-linux
	apt-get -y install libvirt-bin
	apt-get -y install python-libvirt
	sed -i '{:q;N;s/\tpost-up[^][^]*.\n//g;t q}' /etc/network/interfaces
	sed -i 's/inet static/inet static\n\tpost-up ifconfig eth1 0.0.0.0/g' /etc/network/interfaces
	sed -i 's/inet dhcp/inet dhcp\n\tpost-up ifconfig eth1 0.0.0.0/g' /etc/network/interfaces
	ifconfig eth1 0.0.0.0

    touch /etc/nova/nova-compute.conf
    rm /etc/nova/nova.conf
    ln -s /etc/nova/nova-compute.conf /etc/nova/nova.conf

    #echo --s3_hostname=$CLOUD_CONTROLLERIP > /etc/nova/nova-compute.conf
    #echo --osapi_extensions_path=/var/lib/nova/extensions >> /etc/nova/nova-compute.conf
    #echo --verbose >> /etc/nova/nova-compute.conf
    #echo --ec2_dmz_host=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
    #echo --lock_path=/tmp >> /etc/nova/nova-compute.conf
    #echo --glance_api_servers=$CLOUD_CONTROLLERIP:9292 >> /etc/nova/nova-compute.conf
    #echo --auth_driver=nova.auth.dbdriver.DbDriver >> /etc/nova/nova-compute.conf
    #echo --max_cores=16 >> /etc/nova/nova-compute.conf
    #echo --s3_dmz=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
    #echo --osapi_host=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
    #echo --s3_port=80 >> /etc/nova/nova-compute.conf
    #echo --rabbit_host=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
    #echo --my_ip=$CLOUD_MYIP >> /etc/nova/nova-compute.conf
    #echo --ec2_host=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
    #echo --logdir=/var/log/nova >> /etc/nova/nova-compute.conf
    #echo --ec2_port=80 >> /etc/nova/nova-compute.conf
    #echo --sql_connection=mysql://root:$CLOUD_DBPASSWORD@$CLOUD_CONTROLLERIP:3306/nova >> /etc/nova/nova-compute.conf
    #echo --osapi_port=80 >> /etc/nova/nova-compute.conf
    #echo --allow_admin_api >> /etc/nova/nova-compute.conf
    #echo --scheduler_driver=nova.scheduler.simple.SimpleScheduler >> /etc/nova/nova-compute.conf
    #echo --nodaemon >> /etc/nova/nova-compute.conf
    #echo --max_networks=1000 >> /etc/nova/nova-compute.conf
    #echo --max_gigabytes=2048 >> /etc/nova/nova-compute.conf
    #echo --state_path=/var/lib/nova >> /etc/nova/nova-compute.conf
    #echo --image_service=nova.image.glance.GlanceImageService >> /etc/nova/nova-compute.conf
    #echo --use_project_ca >> /etc/nova/nova-compute.conf
    
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
	echo --libvirt_type=$VIRTUALISATION #qemu,kvm >> /etc/nova/nova-compute.conf
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
}