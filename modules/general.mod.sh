verify () {
	nova-manage service list
	verifyAPI
	glance index -A $CLOUD_ADMINTOKEN

	verifyEuca	
}

verifyEuca () {
	mkdir -p ~/creds
	nova-manage db sync
	nova-manage user admin admin
	nova-manage project create admin admin
	nova-manage project zipfile admin admin ~/creds/creds.zip
	cd ~/creds/
	unzip -o creds.zip
	#nova-manage user exports admin >> novarc
	source novarc 
	euca-describe-availability-zones verbose	
    #euca-describe-images --debug
}

verifyAPI () {
	echo "Verify API Connections"
	echo "----------------------"
	echo "Webserver:"
	curl -qs http://$CLOUD_MYIP > /dev/null
	if [ ! $? == 0 ]; then echo -e "\tFAILED"; else echo -e "\tOK"; fi;
	
	echo "EC2 API:"
	curl -qs http://$CLOUD_MYIP:8773 > /dev/null
	if [ ! $? == 0 ]; then echo -e "\tFAILED"; else echo -e "\tOK"; fi;

	echo "S3 API:"
	curl -qs http://$CLOUD_MYIP:3333 > /dev/null
	if [ ! $? == 0 ]; then echo -e "\tFAILED"; else echo -e "\tOK"; fi;
						
	echo "NOVA API:"
	curl -qs http://$CLOUD_MYIP:8774 > /dev/null
	if [ ! $? == 0 ]; then echo -e "\tFAILED"; else echo -e "\tOK"; fi;
		
	echo "Keystone API:"
	curl -qs http://$CLOUD_MYIP:5000 > /dev/null
	if [ ! $? == 0 ]; then echo -e "\tFAILED"; else echo -e "\tOK"; fi;
		
	echo "Keystone Admin API:"
	curl -qs http://$CLOUD_MYIP:35357 > /dev/null
	if [ ! $? == 0 ]; then echo -e "\tFAILED"; else echo -e "\tOK"; fi;
		
	echo "Rabbit MQ:"
	curl -qs http://$CLOUD_MYIP:5672 > /dev/null
	if [ ! $? == 0 ]; then echo -e "\tFAILED"; else echo -e "\tOK"; fi;
		
	echo "Glance Registry:"
	curl -qs http://$CLOUD_MYIP:9191 > /dev/null
	if [ ! $? == 0 ]; then echo -e "\tFAILED"; else echo -e "\tOK"; fi;
	
	echo "Glance API:"
	curl -qs http://$CLOUD_MYIP:9292 > /dev/null
	if [ ! $? == 0 ]; then echo -e "\tFAILED"; else echo -e "\tOK"; fi;
}

installBase () {
    apt-get -y install python-software-properties
    add-apt-repository ppa:nova-core/milestone
    apt-get -y update
    if [ ! "$CLOUD_NEWHOSTNAME" ]; then askForValue "Hostnmae"; export CLOUD_NEWHOSTNAME=$(<"${INPUT}"); fi;
    
    hostname $CLOUD_NEWHOSTNAME 
    echo "$CLOUD_NEWHOSTNAME" > /etc/hostname
    sed -i 's/ubuntu/'$CLOUD_NEWHOSTNAME'/g' /etc/hosts
    apt-get -y install ntp
    sed -i 's/#server ntp.ubuntu.com/ntp.ubuntu.com/g' /etc/ntp.conf
    service ntp stop; ntpdate -u ntp.ubuntu.com; service ntp start
    
    #Openstack
    apt-get -y install nova-common 2>/dev/null | grep "Setting up"
    apt-get -y install nova-compute 2>/dev/null | grep "Setting up"
    apt-get -y install nova-doc 2>/dev/null | grep "Setting up"
    
    ## Global Software
    apt-get -y install git 2>/dev/null | grep "Setting up"
    apt-get -y install python-software-properties 2>/dev/null | grep "Setting up"
    apt-get -y install python-sqlalchemy 2>/dev/null | grep "Setting up"
    apt-get -y install python-mox 2>/dev/null | grep "Setting up"
    apt-get -y install python-greenlet 2>/dev/null | grep "Setting up"
    apt-get -y install python-carrot 2>/dev/null | grep "Setting up"
    apt-get -y install python-migrate 2>/dev/null | grep "Setting up"
    apt-get -y install python-eventlet 2>/dev/null | grep "Setting up"
    apt-get -y install python-gflags 2>/dev/null | grep "Setting up"
    apt-get -y install python-ipy 2>/dev/null | grep "Setting up"
    apt-get -y install python-tempita 2>/dev/null | grep "Setting up"
    apt-get -y install python-libxml2 2>/dev/null | grep "Setting up"
    apt-get -y install python-lxml 2>/dev/null | grep "Setting up"
    apt-get -y install python-routes 2>/dev/null | grep "Setting up"
    apt-get -y install python-cheetah 2>/dev/null | grep "Setting up"
    apt-get -y install python-netaddr 2>/dev/null | grep "Setting up"
    apt-get -y install python-paste 2>/dev/null | grep "Setting up"
    apt-get -y install python-pastedeploy 2>/dev/null | grep "Setting up"
    apt-get -y install python-mysqldb 2>/dev/null | grep "Setting up"
    apt-get -y install python-kombu 2>/dev/null | grep "Setting up"
    apt-get -y install python-novaclient 2>/dev/null | grep "Setting up"
    apt-get -y install python-xattr 2>/dev/null | grep "Setting up"
    apt-get -y install python-glance 2>/dev/null | grep "Setting up"
    apt-get -y install python-lockfile 2>/dev/null | grep "Setting up"
    apt-get -y install python-m2crypto 2>/dev/null | grep "Setting up"
    apt-get -y install python-boto 2>/dev/null | grep "Setting up"
    apt-get -y install gawk 2>/dev/null | grep "Setting up"
    apt-get -y install curl 2>/dev/null | grep "Setting up"
    apt-get -y install socat 2>/dev/null | grep "Setting up"
    apt-get -y install unzip 2>/dev/null | grep "Setting up"
    apt-get -y install vlan 2>/dev/null | grep "Setting up"
    apt-get -y install open-iscsi 2>/dev/null | grep "Setting up"
    apt-get -y install openssh-server 2>/dev/null | grep "Setting up"
    apt-get -y install python-software-properties 2>/dev/null | grep "Setting up"
    apt-get -y install dnsmasq-base 2>/dev/null | grep "Setting up"
    apt-get -y install kpartx 2>/dev/null | grep "Setting up"
    apt-get -y install gawk 2>/dev/null | grep "Setting up"
    apt-get -y install iptables 2>/dev/null | grep "Setting up"
    apt-get -y install ebtables 2>/dev/null | grep "Setting up"
    apt-get -y install user-mode-linux 2>/dev/null | grep "Setting up"
    apt-get -y install libvirt-bin 2>/dev/null | grep "Setting up"
    apt-get -y install euca2ools 2>/dev/null | grep "Setting up"
    apt-get -y install lvm2 2>/dev/null | grep "Setting up"
    apt-get -y install iscsitarget 2>/dev/null | grep "Setting up"
    apt-get -y install python-twisted 2>/dev/null | grep "Setting up"
    apt-get -y install python-libvirt 2>/dev/null | grep "Setting up"
    apt-get -y install python-libxml2 2>/dev/null | grep "Setting up"
    apt-get -y install python-lxml 2>/dev/null | grep "Setting up"
    apt-get -y install python-routes 2>/dev/null | grep "Setting up"
    apt-get -y install python-cheetah 2>/dev/null | grep "Setting up"
    apt-get -y install python-netaddr 2>/dev/null | grep "Setting up"
    apt-get -y install python-paste 2>/dev/null | grep "Setting up"
    apt-get -y install cloud-utils 2>/dev/null | grep "Setting up"
    apt-get -y install collectd-core 2>/dev/null | grep "Setting up"
    apt-get -y install nfs-common 2>/dev/null | grep "Setting up"
    apt-get -y install nfs-kernel-server 2>/dev/null | grep "Setting up"
    apt-get -y install rrdtool 2>/dev/null | grep "Setting up"
}

restartAll () {
	/etc/init.d/rabbitmq-server stop
    /etc/init.d/rabbitmq-server start
	service iscsitarget restart
    restart libvirt-bin
    restart nova-network
    restart nova-compute
    restart nova-api
	restart nova-objectstore
    restart nova-scheduler
    restart nova-volume
    restart keystone
    restart glance-api
    restart glance-registry
    restart nova-vncproxy
    restart nova-ajax-console-proxy
    service apache2 restart
}
