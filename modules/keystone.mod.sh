installKeystone () {
    add-apt-repository -y ppa:keystone-core/trunk
    apt-get update
    apt-get -y install keystone
    apt-get -y install keystone-doc
    apt-get -y install python-keystone

    sed -i 's@default_store = sqlite@default_store = mysql@g' /etc/keystone/keystone.conf
    sed -i 's@log_file = keystone.log@log_file = /var/log/keystone/keystone.log@g' /etc/keystone/keystone.conf
    sed -i 's,sqlite:////var/lib/keystone/keystone.db,mysql://root:'$CLOUD_DBPASSWORD'@'$CLOUD_MYIP':3306/keystone,g' /etc/keystone/keystone.conf

	# fixes the "Unhandled error" for tpl files
	ln -s /usr/share/pyshared/keystone /usr/keystone
    
    restart keystone

}

keystoneAdminToken () {
	export AUTH_TOKEN=`curl -s -d "{\"auth\":{\"passwordCredentials\": {\"username\": \"admin\", \"password\": \"password\"}}}" -H "Content-type: application/json" http://localhost:5000/v2.0/tokens | python -c "import sys; import json; tok = json.loads(sys.stdin.read()); print tok['access']['token']['id'];"`
}

initKeystone () {
    HOST_IP=${HOST_IP:-127.0.0.1}
    export NOVA_PROJECT_ID=${TENANT:-demo}
    export NOVA_USERNAME=admin
    export NOVA_API_KEY=${ADMIN_PASSWORD:-password}
    export NOVA_URL=${NOVA_URL:-http://$HOST_IP:5000/v2.0/}
    export NOVA_VERSION=${NOVA_VERSION:-1.1}
    export NOVA_REGION_NAME=${NOVA_REGION_NAME:-nova}
    export EC2_URL=${EC2_URL:-http://$HOST_IP:80/services/Cloud}
    export EC2_ACCESS_KEY=${NOVA_USERNAME:-demo}
    export EC2_SECRET_KEY=${ADMIN_PASSWORD:-password}
    #export NOVACLIENT_DEBUG=1
    
    export OS_AUTH_USER=$NOVA_USERNAME
    export OS_AUTH_KEY=$NOVA_API_KEY
    export OS_AUTH_TENANT=$NOVA_PROJECT_ID
    export OS_AUTH_URL=$NOVA_URL
    export OS_AUTH_STRATEGY=$NOVA_AUTH_STRATEGY
    
    #?????????
    keystoneAdminToken
        
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf tenant add admin
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf tenant add demo
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf user add admin password
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf user add demo password
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role add Admin
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role add Member
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role add KeystoneAdmin
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role add KeystoneServiceAdmin
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role add sysadmin
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role add netadmin
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role grant Admin admin admin
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role grant Member demo demo
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role grant sysadmin demo demo
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role grant netadmin demo demo
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role grant Admin admin demo
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role grant Admin admin
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role grant KeystoneAdmin admin
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf role grant KeystoneServiceAdmin admin
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf service add nova compute 'Openstack Compute API service'
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf service add glance image 'Openstack Image service'
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf service add keystone identity 'Openstack Keystone service'
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf endpointTemplates add nova nova http://$CLOUD_MYIP:80/v1.1/%tenant_id% http://$CLOUD_MYIP:8774/v1.1/%tenant_id%  http://$CLOUD_MYIP:8774/v1.1/%tenant_id% 1 1
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf endpointTemplates add nova glance http://$CLOUD_MYIP:9292/v1.1/%tenant_id% http://$CLOUD_MYIP:9292/v1.1/%tenant_id% http://$CLOUD_MYIP:9292/v1.1/%tenant_id% 1 1
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf endpointTemplates add nova keystone http://$CLOUD_MYIP:5000/v2.0 http://$CLOUD_MYIP:35357/v2.0 http://$CLOUD_MYIP:5000/v2.0 1 1
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf token add $CLOUD_ADMINTOKEN admin admin 2015-02-05T00:00
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf endpoint add admin 1
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf endpoint add admin 2
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf endpoint add admin 3
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf endpoint add demo 1
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf endpoint add demo 2
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf endpoint add demo 3
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf credentials add admin EC2 'admin' 'password' admin || echo 'no support for adding credentials'
    /usr/bin/keystone-manage -c /etc/keystone/keystone.conf credentials add demo EC2 'demo' 'password' demo || echo 'no support for adding credentials'
}
