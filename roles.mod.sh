controller () {
    installBase
    installController
    initDatabase
    installKeystone
    initKeystone
    installHorizon
    restartAll
    installNetworking
    installVolumes
    echo "You may run ./install.sh installFirstImage to get and install an ubuntu image now"
}
