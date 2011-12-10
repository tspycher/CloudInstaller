controller () {
	installBase
    installController
    initDatabase
    installKeystone
    initKeystone
    installHorizon
    restartAll
}

network () {
	installNetworking
	restartAll
}

volume () {
	installVolumes
	restartAll
}

computeKVM () {
	installBase
	installComputeKVM
	restartAll
}
