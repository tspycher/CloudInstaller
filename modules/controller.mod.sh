installController () {
    # CONTROLLER
    apt-get -y install nova-scheduler 2>/dev/null | grep "Setting up"
    apt-get -y install nova-objectstore 2>/dev/null | grep "Setting up"
    apt-get -y install nova-api 2>/dev/null | grep "Setting up"
    apt-get -y install euca2ools 2>/dev/null | grep "Setting up"
    apt-get -y install cloud-utils 2>/dev/null | grep "Setting up"
    apt-get -y install glance 2>/dev/null | grep "Setting up"
    echo mysql-server-5.1 mysql-server/root_password password $CLOUD_DBPASSWORD | debconf-set-selections
    echo mysql-server-5.1 mysql-server/root_password_again password $CLOUD_DBPASSWORD | debconf-set-selections
    echo mysql-server-5.1 mysql-server/start_on_boot boolean true
    apt-get -y install mysql-server 2>/dev/null | grep "Setting up"
    DEBIAN_FRONTEND=noninteractive apt-get -y install rabbitmq-server
    apt-get -y install apache2 2>/dev/null | grep "Setting up"
    apt-get -y install libapache2-mod-wsgi 2>/dev/null | grep "Setting up"
    apt-get -y install python-setuptools 2>/dev/null | grep "Setting up"
    apt-get -y install python-dev 2>/dev/null | grep "Setting up"
    apt-get -y install python-pastescript 2>/dev/null | grep "Setting up"
    apt-get -y install python-paste 2>/dev/null | grep "Setting up"
    apt-get -y install sqlite3 2>/dev/null | grep "Setting up"
    apt-get -y install python-pysqlite2 2>/dev/null | grep "Setting up"
    apt-get -y install python-webob 2>/dev/null | grep "Setting up"
    apt-get -y install libldap2-dev 2>/dev/null | grep "Setting up"
    apt-get -y install libsasl2-dev 2>/dev/null | grep "Setting up"
    #apt-get -y install python-passlib
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
    service mysql restart

    touch /etc/nova/nova-controller.conf
    rm /etc/nova/nova.conf
    ln -s /etc/nova/nova-controller.conf /etc/nova/nova.conf
    sed -i 's/nova.conf/nova-api.conf/g' /etc/init/nova-api.conf

    a2enmod proxy
    a2enmod proxy_http
    killall dnsmasq
    #rm -fr /root/admin
    #mkdir /root/admin
    #rm -fr /root/stackops
    #mkdir /root/stackops
    #adduser nova --disabled-password --gecos ""
    #rm /var/lib/nova/CA/cacert.pem /var/lib/nova/CA/openssl.cnf /var/lib/nova/CA/crl.pem
    #cd /var/lib/nova/CA; ./genrootca.sh
    #rm /var/lib/nova/CA
    #ln -s /var/lib/nova/nova/CA /var/lib/nova/CA
    #rm /var/lib/nova/bin/nova.conf
    #ln -s /etc/nova/nova-controller.conf /var/lib/nova/bin/nova.conf
    #rm -fr /var/lib/glance/images
    #mkdir -p /var/lib/glance/images
    
    # ----> TODO: ACHTUNG DB PASSWORD IP
    sed -i 's,sqlite:////var/lib/glance/glance.sqlite,mysql://root:'${CLOUD_DBPASSWORD}'@'$CLOUD_MYIP':3306/glance,g' /etc/glance/glance-registry.conf
    sed -i 's,sqlite:////var/lib/glance/glance.sqlite,mysql://root:'${CLOUD_DBPASSWORD}'@'$CLOUD_MYIP':3306/glance,g' /etc/glance/glance-scrubber.conf
    sed -i 's@daemon = False@daemon = True@g' /etc/glance/glance-scrubber.conf
   

	echo --dhcpbridge_flagfile=/etc/nova/nova.conf > /etc/nova/nova-controller.conf
	echo --dhcpbridge=/usr/bin/nova-dhcpbridge >> /etc/nova/nova-controller.conf
	echo --logdir=/var/log/nova >> /etc/nova/nova-controller.conf
	echo --state_path=/var/lib/nova >> /etc/nova/nova-controller.conf
	echo --lock_path=/var/lock/nova >> /etc/nova/nova-controller.conf
	echo --state_path=/var/lib/nova >> /etc/nova/nova-controller.conf
	echo --verbose >> /etc/nova/nova-controller.conf
	echo --s3_host=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
	echo --rabbit_host=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
	echo --cc_host=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
	echo --nova_url=http://$CLOUD_MYIP:8774/v1.1/ >> /etc/nova/nova-controller.conf
	echo --fixed_range=192.168.0.0/16 >> /etc/nova/nova-controller.conf
	echo --network_size=8 >> /etc/nova/nova-controller.conf
	echo --routing_source_ip=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
	echo --sql_connection=mysql://root:$CLOUD_DBPASSWORD@$CLOUD_MYIP/nova >> /etc/nova/nova-controller.conf
	echo --glance_api_servers=$CLOUD_MYIP:9292 >> /etc/nova/nova-controller.conf
	echo --image_service=nova.image.glance.GlanceImageService >> /etc/nova/nova-controller.conf
	echo --iscsi_ip_prefix=192.168. >> /etc/nova/nova-controller.conf
	echo --vlan_interface=br100 >> /etc/nova/nova-controller.conf
	echo --public_interface=eth0 >> /etc/nova/nova-controller.conf


    #echo --s3_hostname=$CLOUD_MYIP > /etc/nova/nova-controller.conf
    #echo --dhcpbridge_flagfile=/etc/nova/nova.conf >> /etc/nova/nova-controller.conf
    #echo --dhcpbridge=/usr/bin/nova-dhcpbridge >> /etc/nova/nova-controller.conf
    #echo --nova_url=http://$CLOUD_MYIP:8774/v1.1/ >> /etc/nova/nova-controller.conf   
    #echo --osapi_extensions_path=/var/lib/nova/extensions >> /etc/nova/nova-controller.conf
    #echo --vncproxy_url=http://$CLOUD_MYIP:6080 >> /etc/nova/nova-controller.conf
    #echo --verbose >> /etc/nova/nova-controller.conf
    #echo --ec2_dmz_host=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
    #echo --lock_path=/tmp >> /etc/nova/nova-controller.conf
    #echo --glance_api_servers=$CLOUD_MYIP:9292 >> /etc/nova/nova-controller.conf
    #echo --auth_driver=nova.auth.dbdriver.DbDriver >> /etc/nova/nova-controller.conf
    #echo --max_cores=16 >> /etc/nova/nova-controller.conf
    #echo --s3_dmz=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
    #echo --osapi_host=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
    #echo --s3_host=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
    #echo --s3_port=80 >> /etc/nova/nova-controller.conf
    #echo --rabbit_host=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
    #echo --cc_host=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
    #echo --my_ip=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
    #echo --ec2_host=$CLOUD_MYIP >> /etc/nova/nova-controller.conf
    #echo --logdir=/var/log/nova >> /etc/nova/nova-controller.conf
    #echo --ec2_port=80 >> /etc/nova/nova-controller.conf
    #echo --sql_connection=mysql://root:$CLOUD_DBPASSWORD@$CLOUD_MYIP:3306/nova >> /etc/nova/nova-controller.conf
    #echo --osapi_port=80 >> /etc/nova/nova-controller.conf
    #echo --allow_admin_api >> /etc/nova/nova-controller.conf
    #echo --scheduler_driver=nova.scheduler.simple.SimpleScheduler >> /etc/nova/nova-controller.conf
    #echo --nodaemon >> /etc/nova/nova-controller.conf
    #echo --max_networks=1000 >> /etc/nova/nova-controller.conf
    #echo --api_paste_config=/var/lib/keystone/examples/paste/nova-api-paste.ini >> /etc/nova/nova-controller.conf
    #echo --max_gigabytes=2048 >> /etc/nova/nova-controller.conf
    #echo --state_path=/var/lib/nova >> /etc/nova/nova-controller.conf
    #echo --image_service=nova.image.glance.GlanceImageService >> /etc/nova/nova-controller.conf
    #echo --use_project_ca >> /etc/nova/nova-controller.conf
    
    echo [DEFAULT] > /etc/nova/nova-api.conf
    echo verbose = 1 >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo ####### >> /etc/nova/nova-api.conf
    echo # EC2 # >> /etc/nova/nova-api.conf
    echo ####### >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [composite:ec2] >> /etc/nova/nova-api.conf
    echo use = egg:Paste#urlmap >> /etc/nova/nova-api.conf
    echo /: ec2versions >> /etc/nova/nova-api.conf
    echo /services/Cloud: ec2cloud >> /etc/nova/nova-api.conf
    echo /services/Admin: ec2admin >> /etc/nova/nova-api.conf
    echo /latest: ec2metadata >> /etc/nova/nova-api.conf
    echo /2007-01-19: ec2metadata >> /etc/nova/nova-api.conf
    echo /2007-03-01: ec2metadata >> /etc/nova/nova-api.conf
    echo /2007-08-29: ec2metadata >> /etc/nova/nova-api.conf
    echo /2007-10-10: ec2metadata >> /etc/nova/nova-api.conf
    echo /2007-12-15: ec2metadata >> /etc/nova/nova-api.conf
    echo /2008-02-01: ec2metadata >> /etc/nova/nova-api.conf
    echo /2008-09-01: ec2metadata >> /etc/nova/nova-api.conf
    echo /2009-04-04: ec2metadata >> /etc/nova/nova-api.conf
    echo /1.0: ec2metadata >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [pipeline:ec2cloud] >> /etc/nova/nova-api.conf
    echo pipeline = logrequest authenticate cloudrequest authorizer ec2executor >> /etc/nova/nova-api.conf
    echo #pipeline = logrequest ec2lockout authenticate cloudrequest authorizer ec2executor >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [pipeline:ec2admin] >> /etc/nova/nova-api.conf
    echo pipeline = logrequest authenticate adminrequest authorizer ec2executor >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [pipeline:ec2metadata] >> /etc/nova/nova-api.conf
    echo pipeline = logrequest ec2md >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [pipeline:ec2versions] >> /etc/nova/nova-api.conf
    echo pipeline = logrequest ec2ver >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [filter:logrequest] >> /etc/nova/nova-api.conf
    echo paste.filter_factory = nova.api.ec2:RequestLogging.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [filter:ec2lockout] >> /etc/nova/nova-api.conf
    echo paste.filter_factory = nova.api.ec2:Lockout.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [filter:authenticate] >> /etc/nova/nova-api.conf
    echo paste.filter_factory = nova.api.ec2:Authenticate.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [filter:cloudrequest] >> /etc/nova/nova-api.conf
    echo controller = nova.api.ec2.cloud.CloudController >> /etc/nova/nova-api.conf
    echo paste.filter_factory = nova.api.ec2:Requestify.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [filter:adminrequest] >> /etc/nova/nova-api.conf
    echo controller = nova.api.ec2.admin.AdminController >> /etc/nova/nova-api.conf
    echo paste.filter_factory = nova.api.ec2:Requestify.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [filter:authorizer] >> /etc/nova/nova-api.conf
    echo paste.filter_factory = nova.api.ec2:Authorizer.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [app:ec2executor] >> /etc/nova/nova-api.conf
    echo paste.app_factory = nova.api.ec2:Executor.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [app:ec2ver] >> /etc/nova/nova-api.conf
    echo paste.app_factory = nova.api.ec2:Versions.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [app:ec2md] >> /etc/nova/nova-api.conf
    echo paste.app_factory = nova.api.ec2.metadatarequesthandler:MetadataRequestHandler.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo ############# >> /etc/nova/nova-api.conf
    echo # Openstack # >> /etc/nova/nova-api.conf
    echo ############# >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [composite:osapi] >> /etc/nova/nova-api.conf
    echo use = egg:Paste#urlmap >> /etc/nova/nova-api.conf
    echo /: osversions >> /etc/nova/nova-api.conf
    echo /v1.0: openstackapi >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [pipeline:openstackapi] >> /etc/nova/nova-api.conf
    echo pipeline = faultwrap auth ratelimit osapiapp >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [filter:faultwrap] >> /etc/nova/nova-api.conf
    echo paste.filter_factory = nova.api.openstack:FaultWrapper.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [filter:auth] >> /etc/nova/nova-api.conf
    echo paste.filter_factory = nova.api.openstack.auth:AuthMiddleware.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [filter:ratelimit] >> /etc/nova/nova-api.conf
    echo paste.filter_factory = nova.api.openstack.ratelimiting:RateLimitingMiddleware.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [app:osapiapp] >> /etc/nova/nova-api.conf
    echo paste.app_factory = nova.api.openstack:APIRouter.factory >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [pipeline:osversions] >> /etc/nova/nova-api.conf
    echo pipeline = faultwrap osversionapp >> /etc/nova/nova-api.conf
    echo  >> /etc/nova/nova-api.conf
    echo [app:osversionapp] >> /etc/nova/nova-api.conf
    echo paste.app_factory = nova.api.openstack:Versions.factory >> /etc/nova/nova-api.conf
    
    chown -R nova:nova /usr/lib/python2.7/dist-packages
    chown -R root:nova /etc/nova
    chmod 640 /etc/nova/nova.conf
}

initDatabase () {
    mysql -uroot -p$CLOUD_DBPASSWORD -e "DROP DATABASE IF EXISTS nova;"
    mysql -uroot -p$CLOUD_DBPASSWORD -e "CREATE DATABASE nova;"
    mysql -uroot -p$CLOUD_DBPASSWORD -e "DROP DATABASE IF EXISTS glance;"
    mysql -uroot -p$CLOUD_DBPASSWORD -e "CREATE DATABASE glance;"
    mysql -uroot -p$CLOUD_DBPASSWORD -e "DROP DATABASE IF EXISTS keystone;"
    mysql -uroot -p$CLOUD_DBPASSWORD -e "CREATE DATABASE keystone;"
    mysql -uroot -p$CLOUD_DBPASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
    mysql -uroot -p$CLOUD_DBPASSWORD -e "SET PASSWORD FOR 'root'@'%' = PASSWORD('$CLOUD_DBPASSWORD');"
    /usr/bin/nova-manage db sync
}
