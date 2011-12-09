export MYLOCALIP=127.0.0.1
export DATABASEPASSWORD=nova

INPUT=/tmp/menu.sh.$$
OUTPUT=/tmp/output.sh.$$

trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

DIALOG=`whereis dialog`
if [ ! $DIALOG ]; then 
    DIALOG=`find /opt -name dialog -print | grep bin 2> /dev/null`
    if [ ! $DIALOG ]; then 
        apt-get -y install dialog 
    fi
fi
echo "Found dialog at $DIALOG"
