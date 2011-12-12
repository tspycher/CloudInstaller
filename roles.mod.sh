controller () {	
	installBase
    installController
    initDatabase
    installKeystone
    initKeystone
    installHorizon
    restartAll
}

horizonOnly () {
	installHorizon
}

keystoneOnly () {
	installKeystone
	initKeystone	
}

network () {
	installNetworking
	restartAll
}

volume () {	
	installVolumes
	restartAll
}

compute () {
	installBase
	installCompute
	restartAll
}
