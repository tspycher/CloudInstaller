installComputeKVM () {
    apt-get -y install nova-compute-kvm

    touch /etc/nova/nova-compute.conf
    rm /etc/nova/nova.conf
    ln -s /etc/nova/nova-compute.conf /etc/nova/nova.conf

    echo --s3_hostname=$CLOUD_CONTROLLERIP > /etc/nova/nova-compute.conf
    echo --osapi_extensions_path=/var/lib/nova/extensions >> /etc/nova/nova-compute.conf
    echo --verbose >> /etc/nova/nova-compute.conf
    echo --ec2_dmz_host=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
    echo --lock_path=/tmp >> /etc/nova/nova-compute.conf
    echo --glance_api_servers=$CLOUD_CONTROLLERIP:9292 >> /etc/nova/nova-compute.conf
    echo --auth_driver=nova.auth.dbdriver.DbDriver >> /etc/nova/nova-compute.conf
    echo --max_cores=16 >> /etc/nova/nova-compute.conf
    echo --s3_dmz=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
    echo --osapi_host=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
    echo --s3_port=80 >> /etc/nova/nova-compute.conf
    echo --rabbit_host=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
    echo --my_ip=$CLOUD_MYIP >> /etc/nova/nova-compute.conf
    echo --ec2_host=$CLOUD_CONTROLLERIP >> /etc/nova/nova-compute.conf
    echo --logdir=/var/log/nova >> /etc/nova/nova-compute.conf
    echo --ec2_port=80 >> /etc/nova/nova-compute.conf
    echo --sql_connection=mysql://root:$CLOUD_DBPASSWORD@$CLOUD_CONTROLLERIP:3306/nova >> /etc/nova/nova-compute.conf
    echo --osapi_port=80 >> /etc/nova/nova-compute.conf
    echo --allow_admin_api >> /etc/nova/nova-compute.conf
    echo --scheduler_driver=nova.scheduler.simple.SimpleScheduler >> /etc/nova/nova-compute.conf
    echo --nodaemon >> /etc/nova/nova-compute.conf
    echo --max_networks=1000 >> /etc/nova/nova-compute.conf
    echo --max_gigabytes=2048 >> /etc/nova/nova-compute.conf
    echo --state_path=/var/lib/nova >> /etc/nova/nova-compute.conf
    echo --image_service=nova.image.glance.GlanceImageService >> /etc/nova/nova-compute.conf
    echo --use_project_ca >> /etc/nova/nova-compute.conf
}
