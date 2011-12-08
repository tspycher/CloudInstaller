export MYLOCALIP=127.0.0.1
export DATABASEPASSWORD=nova

DIALOG=`whereis dialog`
if [ ! $DIALOG ]; then 
    DIALOG=`find /opt -name dialog -print | grep bin 2> /dev/null`
    if [ ! $DIALOG ]; then 
        echo "Dialog nott installed"; 
    fi
fi
echo "Found dialog at $DIALOG"