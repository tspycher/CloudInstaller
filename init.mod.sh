export CLOUD_MYIP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

INPUT=/tmp/menu.sh.$$
OUTPUT=/tmp/output.sh.$$

trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

DIALOG=`whereis -b dialog | awk '{ print $2}'`
if [ ! "$DIALOG" ]; then 
    DIALOG=`find /opt -name dialog -print | grep bin 2> /dev/null`
    if [ ! "$DIALOG" ]; then 
        apt-get -y install dialog 
	exit
    fi
fi

echo "Found dialog at $DIALOG"
export CLOUD_DIALOGBIN=$DIALOG

