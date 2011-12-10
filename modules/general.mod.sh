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
    apt-get -y install nova-common
    apt-get -y install nova-compute
    apt-get -y install nova-doc
    
    ## Global Software
    apt-get -y install git
    apt-get -y install python-software-properties
    apt-get -y install python-sqlalchemy
    apt-get -y install python-mox
    apt-get -y install python-greenlet
    apt-get -y install python-carrot
    apt-get -y install python-migrate
    apt-get -y install python-eventlet
    apt-get -y install python-gflags
    apt-get -y install python-ipy
    apt-get -y install python-tempita
    apt-get -y install python-libxml2
    apt-get -y install python-lxml
    apt-get -y install python-routes
    apt-get -y install python-cheetah
    apt-get -y install python-netaddr
    apt-get -y install python-paste
    apt-get -y install python-pastedeploy
    apt-get -y install python-mysqldb
    apt-get -y install python-kombu
    apt-get -y install python-novaclient
    apt-get -y install python-xattr
    apt-get -y install python-glance
    apt-get -y install python-lockfile
    apt-get -y install python-m2crypto
    apt-get -y install python-boto
    apt-get -y install gawk
    apt-get -y install curl
    apt-get -y install socat
    apt-get -y install unzip
    apt-get -y install vlan
    apt-get -y install open-iscsi
    apt-get -y install openssh-server
    apt-get -y install python-software-properties
    apt-get -y install dnsmasq-base
    apt-get -y install kpartx
    apt-get -y install kvm
    apt-get -y install gawk
    apt-get -y install iptables
    apt-get -y install ebtables
    apt-get -y install user-mode-linux
    apt-get -y install libvirt-bin
    apt-get -y install euca2ools
    apt-get -y install vlan
    apt-get -y install curl
    apt-get -y install lvm2
    apt-get -y install iscsitarget
    apt-get -y install open-iscsi
    apt-get -y install socat
    apt-get -y install python-twisted
    apt-get -y install python-sqlalchemy
    apt-get -y install python-mox
    apt-get -y install python-greenlet
    apt-get -y install python-carrot
    apt-get -y install python-migrate
    apt-get -y install python-eventlet
    apt-get -y install python-gflags
    apt-get -y install python-ipy
    apt-get -y install python-tempita
    apt-get -y install python-libvirt
    apt-get -y install python-libxml2
    apt-get -y install python-lxml
    apt-get -y install python-routes
    apt-get -y install python-cheetah
    apt-get -y install python-netaddr
    apt-get -y install python-paste
    apt-get -y install python-pastedeploy
    apt-get -y install python-mysqldb
    apt-get -y install python-kombu
    apt-get -y install python-novaclient
    apt-get -y install python-xattr
    apt-get -y install python-glance
    apt-get -y install python-lockfile
    apt-get -y install unzip
    apt-get -y install cloud-utils
    apt-get -y install collectd-core
    apt-get -y install nfs-common
    apt-get -y install glance
    apt-get -y install nfs-kernel-server
    apt-get -y install rrdtool
}

restartAll () {
    stop keystone; start keystone
    stop glance-registry; start glance-registry
    stop glance-api; start glance-api
    #stop glance-scrubber; start glance-scrubber
    stop nova-api; start nova-api
    stop nova-scheduler; start nova-scheduler
    stop nova-objectstore; start nova-objectstore
    stop nova-vncproxy; start nova-vncproxy
    stop nova-ajax-console-proxy; start nova-ajax-console-proxy
    service apache2 restart
}
