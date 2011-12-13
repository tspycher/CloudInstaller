installVolumes () {
    # Creating Volumes
    apt-get -y install glance | grep "Setting up"
    apt-get -y install nova-volume | grep "Setting up"
    apt-get -y install kpartx | grep "Setting up"
    apt-get -y install lvm2 | grep "Setting up"
    apt-get -y install iscsitarget | grep "Setting up"
    apt-get -y install iscsitarget-dkms | grep "Setting up"

    sed -i 's/nova.conf/nova-volume.conf/g' /etc/init/nova-volume.conf

    #mv /etc/init/nova-volume.conf.disabled /etc/init/nova-volume.conf
    sed -i 's/false/true/g' /etc/default/iscsitarget
    service iscsitarget start
    
    vgremove -ff nova-volumes; pvcreate -ffy /dev/$CLOUD_ISCSIDISK
    vgcreate nova-volumes /dev/$CLOUD_ISCSIDISK
    
    echo --verbose > /etc/nova/nova-volume.conf
    echo --sql_connection=mysql://root:$CLOUD_DBPASSWORD@$CLOUD_MYIP:3306/nova >> /etc/nova/nova-volume.conf
    echo --lock_path=/tmp >> /etc/nova/nova-volume.conf
    echo --auth_driver=nova.auth.dbdriver.DbDriver >> /etc/nova/nova-volume.conf
    echo --nodaemon >> /etc/nova/nova-volume.conf
    echo --use_local_volumes >> /etc/nova/nova-volume.conf
    echo --rabbit_host=$CLOUD_MYIP >> /etc/nova/nova-volume.conf
    echo --my_ip=$CLOUD_MYIP >> /etc/nova/nova-volume.conf
    echo --state_path=/var/lib/nova >> /etc/nova/nova-volume.conf
    echo --logdir=/var/log/nova >> /etc/nova/nova-volume.conf
    echo --use_project_ca >> /etc/nova/nova-volume.conf
    
    # Configure Glance for keystone auth
    sed -i 's/pipeline = context/pipeline = authtoken keystone_shim context/g' /etc/glance/glance-registry.conf
    sed -i 's/pipeline = versionnegotiation/pipeline = versionnegotiation authtoken/g' /etc/glance/glance-api.conf
    
    stop nova-volume; start nova-volume
    /etc/init.d/glance-api stop; /etc/init.d/glance-api start
    /etc/init.d/glance-registry stop; /etc/init.d/glance-registry start
}

installImage () {
    defCode=oneiric #10.10
    defType=server

    CODE=${1:-$defCode}
    TYPE=${2:-$defType}

    IMAGE_NAME="$CODE-$TYPE-cloudimg-amd64"
    IMAGE_FRIENDLYNAME="Ubuntu-$CODE-$TYPE"

    echo "Downloading images $IMAGE_NAME..."
    if [ ! -e "/tmp/$IMAGE_NAME.tar.gz" ]; then 
        wget -nv http://cloud-images.ubuntu.com/$CODE/current/$IMAGE_NAME.tar.gz -O /tmp/$IMAGE_NAME.tar.gz
    fi

    if [ ! -e "/tmp/$IMAGE_NAME.tar.gz" ]; then return 1; fi

    mkdir -p /tmp/images
    if [ ! -e "/tmp/images/$IMAGE_NAME.img" ]; then
        tar -zxf /tmp/$IMAGE_NAME.tar.gz  -C /tmp/images
    fi

    RVAL=`glance add -A $CLOUD_ADMINTOKEN name="$IMAGE_FRIENDLYNAME-kernel" is_public=true container_format=aki disk_format=aki < /tmp/images/$IMAGE_NAME-vmlinuz*`
    KERNEL_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`
    glance add -A $CLOUD_ADMINTOKEN name="$IMAGE_FRIENDLYNAME" is_public=true container_format=ami disk_format=ami kernel_id=$KERNEL_ID < /tmp/images/$IMAGE_NAME.img    
}
