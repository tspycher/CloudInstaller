installVolumes () {
    # Creating Volumes
    apt-get -y install nova-volume
    apt-get -y install kpartx
    apt-get -y install lvm2
    apt-get -y install iscsitarget
    apt-get -y install iscsitarget-dkms
    #mv /etc/init/nova-volume.conf.disabled /etc/init/nova-volume.conf
    sed -i 's/false/true/g' /etc/default/iscsitarget
    service iscsitarget start
    
    vgremove -ff nova-volumes; pvcreate -ffy /dev/sdb
    vgcreate nova-volumes /dev/sdb
    
    echo --verbose > /etc/nova/nova-volume.conf
    echo --sql_connection=mysql://root:$DATABASEPASSWORD@$MYLOCALIP:3306/nova >> /etc/nova/nova-volume.conf
    echo --lock_path=/tmp >> /etc/nova/nova-volume.conf
    echo --auth_driver=nova.auth.dbdriver.DbDriver >> /etc/nova/nova-volume.conf
    echo --nodaemon >> /etc/nova/nova-volume.conf
    echo --use_local_volumes >> /etc/nova/nova-volume.conf
    echo --rabbit_host=$MYLOCALIP >> /etc/nova/nova-volume.conf
    echo --my_ip=$MYLOCALIP >> /etc/nova/nova-volume.conf
    echo --state_path=/var/lib/nova >> /etc/nova/nova-volume.conf
    echo --logdir=/var/log/nova >> /etc/nova/nova-volume.conf
    echo --use_project_ca >> /etc/nova/nova-volume.conf
    
    # Configure Glance for keystone auth
    sed -i 's/pipeline = context/pipeline = authtoken keystone_shim context/g' /etc/glance/glance-registry.conf
    sed -i 's/pipeline = versionnegotiation/pipeline = versionnegotiation authtoken/g' /etc/glance/glance-registry.conf
    
    stop nova-volume; start nova-volume
    /etc/init.d/glance-api stop; /etc/init.d/glance-api start
    /etc/init.d/glance-registry stop; /etc/init.d/glance-registry start
}

installFirstImage () {
    SERVICE_TOKEN=999888777666
    IMAGE_NAME='lucid-server-cloudimg-amd64'
    echo "Downloading images..."
    wget http://cloud-images.ubuntu.com/lucid/current/$IMAGE_NAME.tar.gz -O /tmp/$IMAGE_NAME.tar.gz
    
    mkdir -p /tmp/images
    tar -zxf /tmp/$IMAGE_NAME.tar.gz  -C /tmp/images
    
    RVAL=`glance add -A $SERVICE_TOKEN name="ubuntu-10.04.2-kernel" is_public=true container_format=aki disk_format=aki < /tmp/images/$IMAGE_NAME-vmlinuz*`
    KERNEL_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`
    glance add -A $SERVICE_TOKEN name="ubuntu-10.04.2" is_public=true container_format=ami disk_format=ami kernel_id=$KERNEL_ID < /tmp/images/$IMAGE_NAME.img
    glance index -A $SERVICE_TOKEN
}