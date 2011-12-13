installNetworking () {
	CONFIGFILE=/etc/nova/nova-network.conf.cloudinstaller
    ## NETWORKING
    apt-get -y install nova-network | grep "Setting up"
    apt-get -y install bridge-utils | grep "Setting up"
    apt-get -y install dnsmasq-base | grep "Setting up"
    apt-get -y install iptables | grep "Setting up"
    apt-get -y install ebtables | grep "Setting up"

    #sed -i 's/nova.conf/nova-network.conf/g' /etc/init/nova-network.conf

    echo "dummy" >> /etc/modules
    modprobe dummy
    ifconfig dummy0 0.0.0.0
    #rm /var/lib/nova/bin/nova.conf
    #ln -s $CONFIGFILE /var/lib/nova/bin/nova.conf
    sed -i '{:q;N;s/\tpost-up[^][^]*.\n//g;t q}' /etc/network/interfaces
    sed -i 's/inet static/inet static\n\tpost-up ifconfig eth1 0.0.0.0/g' /etc/network/interfaces
    sed -i 's/inet dhcp/inet dhcp\n\tpost-up ifconfig eth1 0.0.0.0/g' /etc/network/interfaces
    ifconfig eth1 0.0.0.0
    nova-manage network create service 10.0.0.0/8 1 256 --bridge=br100 --bridge_interface=eth1 --dns1=8.8.8.8 --dns2=8.8.4.4
    nova-manage float create 172.16.1.0/24
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
    #mv /etc/init/nova-network.conf.disabled /etc/init/nova-network.conf
    
    echo --dhcpbridge_flagfile=$CONFIGFILE > $CONFIGFILE
    echo --verbose >> $CONFIGFILE
    echo --rabbit_host=$CLOUD_MYIP >> $CONFIGFILE
    echo --my_ip=$CLOUD_MYIP >> $CONFIGFILE
    echo --dhcpbridge=/usr/bin/nova-dhcpbridge >> $CONFIGFILE
    echo --sql_connection=mysql://root:$CLOUD_DBPASSWORD@$CLOUD_MYIP:3306/nova >> $CONFIGFILE
    echo --ec2_dmz_host=$CLOUD_MYIP >> $CONFIGFILE
    echo --lock_path=/tmp >> $CONFIGFILE
    echo --state_path=/var/lib/nova >> $CONFIGFILE
    echo --flat_network_dhcp_start=10.0.0.2 >> $CONFIGFILE
    echo --auth_driver=nova.auth.dbdriver.DbDriver >> $CONFIGFILE
    echo --network_manager=nova.network.manager.FlatDHCPManager >> $CONFIGFILE
    echo --ec2_host=$CLOUD_MYIP >> $CONFIGFILE
    echo --logdir=/var/log/nova >> $CONFIGFILE
    echo --public_interface=eth0 >> $CONFIGFILE
    echo --use_project_ca >> $CONFIGFILE
    echo --nodaemon >> $CONFIGFILE
    echo --routing_source_ip=$CLOUD_MYIP >> $CONFIGFILE
    
    restartAll
}
