if [ -e "preseed.conf" ]; then source preseed.conf; fi

export CLOUD_MYIP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

# Loading all modules
for file in ./modules/*; do source ${file}; done;

INPUT=/tmp/input.$$
OUTPUT=/tmp/output.$$

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

