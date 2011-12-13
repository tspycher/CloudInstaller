verify () {
	nova-manage service list
	glance index -A $CLOUD_ADMINTOKEN
}

installBase () {
    apt-get -y update
    
    hostname $CLOUD_NEWHOSTNAME 
    echo "$CLOUD_NEWHOSTNAME" > /etc/hostname
    sed -i 's/ubuntu/'$CLOUD_NEWHOSTNAME'/g' /etc/hosts
    apt-get -y install ntp
    sed -i 's/#server ntp.ubuntu.com/ntp.ubuntu.com/g' /etc/ntp.conf
    service ntp stop; ntpdate -u ntp.ubuntu.com; service ntp start
    
    #Openstack
    apt-get -y install nova-common | grep "Setting up"
    apt-get -y install nova-compute | grep "Setting up"
    apt-get -y install nova-doc | grep "Setting up"
    
    ## Global Software
    apt-get -y install git | grep "Setting up"
    apt-get -y install python-software-properties | grep "Setting up"
    apt-get -y install python-sqlalchemy | grep "Setting up"
    apt-get -y install python-mox | grep "Setting up"
    apt-get -y install python-greenlet | grep "Setting up"
    apt-get -y install python-carrot | grep "Setting up"
    apt-get -y install python-migrate | grep "Setting up"
    apt-get -y install python-eventlet | grep "Setting up"
    apt-get -y install python-gflags | grep "Setting up"
    apt-get -y install python-ipy | grep "Setting up"
    apt-get -y install python-tempita | grep "Setting up"
    apt-get -y install python-libxml2 | grep "Setting up"
    apt-get -y install python-lxml | grep "Setting up"
    apt-get -y install python-routes | grep "Setting up"
    apt-get -y install python-cheetah | grep "Setting up"
    apt-get -y install python-netaddr | grep "Setting up"
    apt-get -y install python-paste | grep "Setting up"
    apt-get -y install python-pastedeploy | grep "Setting up"
    apt-get -y install python-mysqldb | grep "Setting up"
    apt-get -y install python-kombu | grep "Setting up"
    apt-get -y install python-novaclient | grep "Setting up"
    apt-get -y install python-xattr | grep "Setting up"
    apt-get -y install python-glance | grep "Setting up"
    apt-get -y install python-lockfile | grep "Setting up"
    apt-get -y install python-m2crypto | grep "Setting up"
    apt-get -y install python-boto | grep "Setting up"
    apt-get -y install gawk | grep "Setting up"
    apt-get -y install curl | grep "Setting up"
    apt-get -y install socat | grep "Setting up"
    apt-get -y install unzip | grep "Setting up"
    apt-get -y install vlan | grep "Setting up"
    apt-get -y install open-iscsi | grep "Setting up"
    apt-get -y install openssh-server | grep "Setting up"
    apt-get -y install python-software-properties | grep "Setting up"
    apt-get -y install dnsmasq-base | grep "Setting up"
    apt-get -y install kpartx | grep "Setting up"
    apt-get -y install kvm | grep "Setting up"
    apt-get -y install gawk | grep "Setting up"
    apt-get -y install iptables | grep "Setting up"
    apt-get -y install ebtables | grep "Setting up"
    apt-get -y install user-mode-linux | grep "Setting up"
    apt-get -y install libvirt-bin | grep "Setting up"
    apt-get -y install euca2ools | grep "Setting up"
    apt-get -y install lvm2 | grep "Setting up"
    apt-get -y install iscsitarget | grep "Setting up"
    apt-get -y install python-twisted | grep "Setting up"
    apt-get -y install python-libvirt | grep "Setting up"
    apt-get -y install python-libxml2 | grep "Setting up"
    apt-get -y install python-lxml | grep "Setting up"
    apt-get -y install python-routes | grep "Setting up"
    apt-get -y install python-cheetah | grep "Setting up"
    apt-get -y install python-netaddr | grep "Setting up"
    apt-get -y install python-paste | grep "Setting up"
    apt-get -y install cloud-utils | grep "Setting up"
    apt-get -y install collectd-core | grep "Setting up"
    apt-get -y install nfs-common | grep "Setting up"
    apt-get -y install nfs-kernel-server | grep "Setting up"
    apt-get -y install rrdtool | grep "Setting up"
}

restartAll () {
    /etc/init.d/rabbitmq-server stop
    /etc/init.d/rabbitmq-server start
    stop keystone; start keystone
    stop glance-registry; start glance-registry
    stop glance-api; start glance-api
    #stop glance-scrubber; start glance-scrubber
    stop nova-api; start nova-api
    stop nova-scheduler; start nova-scheduler
    stop nova-objectstore; start nova-objectstore
    stop nova-vncproxy; start nova-vncproxy
    stop nova-ajax-console-proxy; start nova-ajax-console-proxy
    stop nova-compute; start nova-compute
    service apache2 restart
}
