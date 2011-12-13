installController () {
    CONFIGFILE=/etc/nova/nova-controller.conf.cloudinstaller
    CONFIGFILEAPI=/etc/nova/nova-api.conf.cloudinstaller
    
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

    #touch $CONFIGFILE
    #mv /etc/nova/nova.conf /etc/nova/nova.conf.dist
    #ln -s $CONFIGFILE /etc/nova/nova.conf
    #sed -i 's/nova.conf/nova-api.conf/g' /etc/init/nova-api.conf

    a2enmod proxy
    a2enmod proxy_http
    #killall dnsmasq
    
    sed -i 's,sqlite:////var/lib/glance/glance.sqlite,mysql://root:'${CLOUD_DBPASSWORD}'@'$CLOUD_MYIP':3306/glance,g' /etc/glance/glance-registry.conf
    sed -i 's,sqlite:////var/lib/glance/glance.sqlite,mysql://root:'${CLOUD_DBPASSWORD}'@'$CLOUD_MYIP':3306/glance,g' /etc/glance/glance-scrubber.conf
    sed -i 's@daemon = False@daemon = True@g' /etc/glance/glance-scrubber.conf
   

	echo --dhcpbridge_flagfile=/etc/nova/nova.conf > $CONFIGFILE
	echo --dhcpbridge=/usr/bin/nova-dhcpbridge >> $CONFIGFILE
	echo --logdir=/var/log/nova >> $CONFIGFILE
	echo --state_path=/var/lib/nova >> $CONFIGFILE
	echo --lock_path=/var/lock/nova >> $CONFIGFILE
	echo --state_path=/var/lib/nova >> $CONFIGFILE
	echo --verbose >> $CONFIGFILE
	echo --s3_host=$CLOUD_MYIP >> $CONFIGFILE
	echo --rabbit_host=$CLOUD_MYIP >> $CONFIGFILE
	echo --cc_host=$CLOUD_MYIP >> $CONFIGFILE
	echo --nova_url=http://$CLOUD_MYIP:8774/v1.1/ >> $CONFIGFILE
	echo --fixed_range=192.168.0.0/16 >> $CONFIGFILE
	echo --network_size=8 >> $CONFIGFILE
	echo --routing_source_ip=$CLOUD_MYIP >> $CONFIGFILE
	echo --sql_connection=mysql://root:$CLOUD_DBPASSWORD@$CLOUD_MYIP/nova >> $CONFIGFILE
	echo --glance_api_servers=$CLOUD_MYIP:9292 >> $CONFIGFILE
	echo --image_service=nova.image.glance.GlanceImageService >> $CONFIGFILE
	echo --iscsi_ip_prefix=192.168. >> $CONFIGFILE
	echo --vlan_interface=br100 >> $CONFIGFILE
	echo --public_interface=eth0 >> $CONFIGFILE


    #echo --s3_hostname=$CLOUD_MYIP > $CONFIGFILE
    #echo --dhcpbridge_flagfile=/etc/nova/nova.conf >> $CONFIGFILE
    #echo --dhcpbridge=/usr/bin/nova-dhcpbridge >> $CONFIGFILE
    #echo --nova_url=http://$CLOUD_MYIP:8774/v1.1/ >> $CONFIGFILE   
    #echo --osapi_extensions_path=/var/lib/nova/extensions >> $CONFIGFILE
    #echo --vncproxy_url=http://$CLOUD_MYIP:6080 >> $CONFIGFILE
    #echo --verbose >> $CONFIGFILE
    #echo --ec2_dmz_host=$CLOUD_MYIP >> $CONFIGFILE
    #echo --lock_path=/tmp >> $CONFIGFILE
    #echo --glance_api_servers=$CLOUD_MYIP:9292 >> $CONFIGFILE
    #echo --auth_driver=nova.auth.dbdriver.DbDriver >> $CONFIGFILE
    #echo --max_cores=16 >> $CONFIGFILE
    #echo --s3_dmz=$CLOUD_MYIP >> $CONFIGFILE
    #echo --osapi_host=$CLOUD_MYIP >> $CONFIGFILE
    #echo --s3_host=$CLOUD_MYIP >> $CONFIGFILE
    #echo --s3_port=80 >> $CONFIGFILE
    #echo --rabbit_host=$CLOUD_MYIP >> $CONFIGFILE
    #echo --cc_host=$CLOUD_MYIP >> $CONFIGFILE
    #echo --my_ip=$CLOUD_MYIP >> $CONFIGFILE
    #echo --ec2_host=$CLOUD_MYIP >> $CONFIGFILE
    #echo --logdir=/var/log/nova >> $CONFIGFILE
    #echo --ec2_port=80 >> $CONFIGFILE
    #echo --sql_connection=mysql://root:$CLOUD_DBPASSWORD@$CLOUD_MYIP:3306/nova >> $CONFIGFILE
    #echo --osapi_port=80 >> $CONFIGFILE
    #echo --allow_admin_api >> $CONFIGFILE
    #echo --scheduler_driver=nova.scheduler.simple.SimpleScheduler >> $CONFIGFILE
    #echo --nodaemon >> $CONFIGFILE
    #echo --max_networks=1000 >> $CONFIGFILE
    #echo --api_paste_config=/var/lib/keystone/examples/paste/nova-api-paste.ini >> $CONFIGFILE
    #echo --max_gigabytes=2048 >> $CONFIGFILE
    #echo --state_path=/var/lib/nova >> $CONFIGFILE
    #echo --image_service=nova.image.glance.GlanceImageService >> $CONFIGFILE
    #echo --use_project_ca >> $CONFIGFILE
    
    #echo [DEFAULT] > $CONFIGFILEAPI
    #echo verbose = 1 >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo ####### >> $CONFIGFILEAPI
    #echo # EC2 # >> $CONFIGFILEAPI
    #echo ####### >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [composite:ec2] >> $CONFIGFILEAPI
    #echo use = egg:Paste#urlmap >> $CONFIGFILEAPI
    #echo /: ec2versions >> $CONFIGFILEAPI
    #echo /services/Cloud: ec2cloud >> $CONFIGFILEAPI
    #echo /services/Admin: ec2admin >> $CONFIGFILEAPI
    #echo /latest: ec2metadata >> $CONFIGFILEAPI
    #echo /2007-01-19: ec2metadata >> $CONFIGFILEAPI
    #echo /2007-03-01: ec2metadata >> $CONFIGFILEAPI
    #echo /2007-08-29: ec2metadata >> $CONFIGFILEAPI
    #echo /2007-10-10: ec2metadata >> $CONFIGFILEAPI
    #echo /2007-12-15: ec2metadata >> $CONFIGFILEAPI
    #echo /2008-02-01: ec2metadata >> $CONFIGFILEAPI
    #echo /2008-09-01: ec2metadata >> $CONFIGFILEAPI
    #echo /2009-04-04: ec2metadata >> $CONFIGFILEAPI
    #echo /1.0: ec2metadata >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [pipeline:ec2cloud] >> $CONFIGFILEAPI
    #echo pipeline = logrequest authenticate cloudrequest authorizer ec2executor >> $CONFIGFILEAPI
    #echo #pipeline = logrequest ec2lockout authenticate cloudrequest authorizer ec2executor >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [pipeline:ec2admin] >> $CONFIGFILEAPI
    #echo pipeline = logrequest authenticate adminrequest authorizer ec2executor >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [pipeline:ec2metadata] >> $CONFIGFILEAPI
    #echo pipeline = logrequest ec2md >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [pipeline:ec2versions] >> $CONFIGFILEAPI
    #echo pipeline = logrequest ec2ver >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [filter:logrequest] >> $CONFIGFILEAPI
    #echo paste.filter_factory = nova.api.ec2:RequestLogging.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [filter:ec2lockout] >> $CONFIGFILEAPI
    #echo paste.filter_factory = nova.api.ec2:Lockout.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [filter:authenticate] >> $CONFIGFILEAPI
    #echo paste.filter_factory = nova.api.ec2:Authenticate.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [filter:cloudrequest] >> $CONFIGFILEAPI
    #echo controller = nova.api.ec2.cloud.CloudController >> $CONFIGFILEAPI
    #echo paste.filter_factory = nova.api.ec2:Requestify.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [filter:adminrequest] >> $CONFIGFILEAPI
    #echo controller = nova.api.ec2.admin.AdminController >> $CONFIGFILEAPI
    #echo paste.filter_factory = nova.api.ec2:Requestify.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [filter:authorizer] >> $CONFIGFILEAPI
    #echo paste.filter_factory = nova.api.ec2:Authorizer.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [app:ec2executor] >> $CONFIGFILEAPI
    #echo paste.app_factory = nova.api.ec2:Executor.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [app:ec2ver] >> $CONFIGFILEAPI
    #echo paste.app_factory = nova.api.ec2:Versions.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [app:ec2md] >> $CONFIGFILEAPI
    #echo paste.app_factory = nova.api.ec2.metadatarequesthandler:MetadataRequestHandler.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo ############# >> $CONFIGFILEAPI
    #echo # Openstack # >> $CONFIGFILEAPI
    #echo ############# >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [composite:osapi] >> $CONFIGFILEAPI
    #echo use = egg:Paste#urlmap >> $CONFIGFILEAPI
    #echo /: osversions >> $CONFIGFILEAPI
    #echo /v1.0: openstackapi >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [pipeline:openstackapi] >> $CONFIGFILEAPI
    #echo pipeline = faultwrap auth ratelimit osapiapp >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [filter:faultwrap] >> $CONFIGFILEAPI
    #echo paste.filter_factory = nova.api.openstack:FaultWrapper.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [filter:auth] >> $CONFIGFILEAPI
    #echo paste.filter_factory = nova.api.openstack.auth:AuthMiddleware.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [filter:ratelimit] >> $CONFIGFILEAPI
    #echo paste.filter_factory = nova.api.openstack.ratelimiting:RateLimitingMiddleware.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [app:osapiapp] >> $CONFIGFILEAPI
    #echo paste.app_factory = nova.api.openstack:APIRouter.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    #echo [pipeline:osversions] >> $CONFIGFILEAPI
    #echo pipeline = faultwrap osversionapp >> $CONFIGFILEAPI
    #echo [app:osversionapp] >> $CONFIGFILEAPI
    #echo paste.app_factory = nova.api.openstack:Versions.factory >> $CONFIGFILEAPI
    #echo  >> $CONFIGFILEAPI
    
    chown -R nova:nova /usr/lib/python2.7/dist-packages
    chown -R root:nova /etc/nova
    chmod 640 /etc/nova/nova.conf
    
    restartAll
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
