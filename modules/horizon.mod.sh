HORIZONBASE=/usr/share/openstack-dashboard-dev

installHorizonDev () {
	CURRENT=1
	
	if [ -e $HORIZONBASE ]; then
		tar -cvzf $HORIZONBASE/../horizon_backup.tar.gz $HORIZONBASE
		rm -rf $HORIZONBASE
	fi

	apt-get -y install python-virtualenv python-pip virtualenvwrapper | grep "Setting up"
	
	mkdir -p $HORIZONBASE
	if [ $CURRENT != 0 ]; then
		git clone https://github.com/openstack/horizon.git $HORIZONBASE
	else
		git clone https://github.com/4P/horizon $HORIZONBASE
	fi
	
	cd $HORIZONBASE/openstack-dashboard/
    cp $HORIZONBASE/openstack-dashboard/local/local_settings.py.example $HORIZONBASE/openstack-dashboard/local/local_settings.py
    echo "OPENSTACK_ADMIN_TOKEN = \"999888777666\"" >> $HORIZONBASE/openstack-dashboard/local/local_settings.py
	
	if [ $CURRENT == 0 ]; then	
		# https://github.com/openstack/quantum.git#egg=quantum
		# with	
		# https://github.com/openstack/quantum.git@stable/diablo#egg=quantum
		sed -i 's/quantum.git#egg=quantum/quantum.git@stable\/diablo#egg=quantum/g' $HORIZONBASE/openstack-dashboard/tools/pip-requires
		echo 'pycrypto >= 2.2' >> $HORIZONBASE/openstack-dashboard/tools/pip-requires
	fi
	
	python $HORIZONBASE/openstack-dashboard/tools/install_venv.py

	$HORIZONBASE/openstack-dashboard/tools/with_venv.sh $HORIZONBASE/openstack-dashboard/dashboard/manage.py syncdb
}


startHorizonDev () {
	clear
	echo -e "Starting the Horizon Dev Server..."
	$HORIZONBASE/openstack-dashboard/tools/with_venv.sh $HORIZONBASE/openstack-dashboard/dashboard/manage.py runserver 0.0.0.0:8001
}

installHorizon () {
    installHorizonDev
    
    apt-get -y install openstack-dashboard 2>/dev/null | grep "Setting up"
    apt-get -y install nova-vncproxy 2>/dev/null | grep "Setting up"
    apt-get -y install nova-ajax-console-proxy 2>/dev/null | grep "Setting up"
    sudo easy_install virtualenv

    mkdir -p ~/src
    cd  ~/src
    git clone https://github.com/4P/horizon.git
    git clone https://github.com/cloudbuilders/openstackx.git
    cd horizon; python django-openstack/setup.py install; cd ..;
    cd openstackx; python setup.py install; cd ..;
    cd

    chown -R nova:nova /var/lib/openstack-dashboard/    
    # Horizon
    cp /usr/share/openstack-dashboard/local/local_settings.py.example /usr/share/openstack-dashboard/local/local_settings.py
    ln -s /usr/share/openstack-dashboard/local /etc/openstack-dashboard/local
    sudo -u nova /usr/share/openstack-dashboard/dashboard/manage.py syncdb
    
    echo > /etc/apache2/sites-available/default
    echo WSGIRestrictStdout Off >> /etc/apache2/sites-available/default
    echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/default
    echo ServerAdmin webmaster@localhost >> /etc/apache2/sites-available/default
    echo >> /etc/apache2/sites-available/default
    echo ProxyPreserveHost On >> /etc/apache2/sites-available/default
    echo ProxyRequests Off >> /etc/apache2/sites-available/default
    echo >> /etc/apache2/sites-available/default
    echo ProxyPass /services http://127.0.0.1:8773/services >> /etc/apache2/sites-available/default
    echo ProxyPassReverse /services http://127.0.0.1:8773/services >> /etc/apache2/sites-available/default
    echo >> /etc/apache2/sites-available/default
    echo ProxyPass /v1.1 http://127.0.0.1:8774/v1.1 >> /etc/apache2/sites-available/default
    echo ProxyPassReverse /v1.1 http://127.0.0.1:8774/v1.1 >> /etc/apache2/sites-available/default
    echo >> /etc/apache2/sites-available/default
    echo ProxyPass /v1.0 http://127.0.0.1:8774/v1.0 >> /etc/apache2/sites-available/default
    echo ProxyPassReverse /v1.0 http://127.0.0.1:8774/v1.0 >> /etc/apache2/sites-available/default
    echo  >> /etc/apache2/sites-available/default
    echo WSGIScriptAlias / /usr/share/openstack-dashboard/dashboard/wsgi/django.wsgi >> /etc/apache2/sites-available/default
    echo WSGIDaemonProcess horizon user=nova group=nova processes=3 threads=10 python-path=/usr/share/openstack-dashboard >> /etc/apache2/sites-available/default
    echo SetEnv APACHE_RUN_USER nova >> /etc/apache2/sites-available/default
    echo SetEnv APACHE_RUN_GROUP nova >> /etc/apache2/sites-available/default
    echo WSGIProcessGroup horizon >> /etc/apache2/sites-available/default
    echo  >> /etc/apache2/sites-available/default
    echo Alias /media /usr/share/openstack-dashboard/media >> /etc/apache2/sites-available/default
    echo  >> /etc/apache2/sites-available/default
    echo "<Directory />" >> /etc/apache2/sites-available/default
    #echo SetHandler python-program
    echo Options FollowSymLinks >> /etc/apache2/sites-available/default
    echo AllowOverride None >> /etc/apache2/sites-available/default
    echo "</Directory>" >> /etc/apache2/sites-available/default
    echo >> /etc/apache2/sites-available/default
    echo "<Directory /usr/share/openstack-dashboard/>" >> /etc/apache2/sites-available/default
    echo Options Indexes FollowSymLinks MultiViews >> /etc/apache2/sites-available/default
    echo AllowOverride None >> /etc/apache2/sites-available/default
    echo Order allow,deny >> /etc/apache2/sites-available/default
    echo allow from all >> /etc/apache2/sites-available/default
    echo "</Directory>" >> /etc/apache2/sites-available/default
    echo  >> /etc/apache2/sites-available/default
    echo "<Proxy *>" >> /etc/apache2/sites-available/default
    echo Order allow,deny >> /etc/apache2/sites-available/default
    echo Allow from all >> /etc/apache2/sites-available/default
    echo "</Proxy>" >> /etc/apache2/sites-available/default
    echo  >> /etc/apache2/sites-available/default
    echo ErrorLog /var/log/nova/apache-error.log >> /etc/apache2/sites-available/default
    echo TransferLog /var/log/nova/apache-access.log >> /etc/apache2/sites-available/default
    echo "</VirtualHost>" >> /etc/apache2/sites-available/default

	restartAll
}
