installNetworking () {    
    ## NETWORKING
    apt-get -y install nova-network
    apt-get -y install bridge-utils
    apt-get -y install dnsmasq-base
    apt-get -y install iptables
    apt-get -y install ebtables

    sed -i 's/nova.conf/nova-network.conf/g' /etc/init/nova-network.conf

    echo "dummy" >> /etc/modules
    modprobe dummy
    ifconfig dummy0 0.0.0.0
    #rm /var/lib/nova/bin/nova.conf
    #ln -s /etc/nova/nova-network.conf /var/lib/nova/bin/nova.conf
    sed -i '{:q;N;s/\tpost-up[^][^]*.\n//g;t q}' /etc/network/interfaces
    sed -i 's/inet static/inet static\n\tpost-up ifconfig eth1 0.0.0.0/g' /etc/network/interfaces
    sed -i 's/inet dhcp/inet dhcp\n\tpost-up ifconfig eth1 0.0.0.0/g' /etc/network/interfaces
    ifconfig eth1 0.0.0.0
    /usr/bin/nova-manage network create service 10.0.0.0/8 1 256 --bridge=br100 --bridge_interface=eth1 --dns1=8.8.8.8 --dns2=8.8.4.4
    /usr/bin/nova-manage float create 172.16.1.0/24
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
    #mv /etc/init/nova-network.conf.disabled /etc/init/nova-network.conf
    
    echo --dhcpbridge_flagfile=/etc/nova/nova-network.conf > /etc/nova/nova-network.conf
    echo --verbose >> /etc/nova/nova-network.conf
    echo --rabbit_host=$MYLOCALIP >> /etc/nova/nova-network.conf
    echo --my_ip=$MYLOCALIP >> /etc/nova/nova-network.conf
    echo --dhcpbridge=/usr/bin/nova-dhcpbridge >> /etc/nova/nova-network.conf
    echo --sql_connection=mysql://root:$DATABASEPASSWORD@$MYLOCALIP:3306/nova >> /etc/nova/nova-network.conf
    echo --ec2_dmz_host=$MYLOCALIP >> /etc/nova/nova-network.conf
    echo --lock_path=/tmp >> /etc/nova/nova-network.conf
    echo --state_path=/var/lib/nova >> /etc/nova/nova-network.conf
    echo --flat_network_dhcp_start=10.0.0.2 >> /etc/nova/nova-network.conf
    echo --auth_driver=nova.auth.dbdriver.DbDriver >> /etc/nova/nova-network.conf
    echo --network_manager=nova.network.manager.FlatDHCPManager >> /etc/nova/nova-network.conf
    echo --ec2_host=$MYLOCALIP >> /etc/nova/nova-network.conf
    echo --logdir=/var/log/nova >> /etc/nova/nova-network.conf
    echo --public_interface=eth0 >> /etc/nova/nova-network.conf
    echo --use_project_ca >> /etc/nova/nova-network.conf
    echo --nodaemon >> /etc/nova/nova-network.conf
    echo --routing_source_ip=$MYLOCALIP >> /etc/nova/nova-network.conf
    
    stop nova-network; start nova-network
}
