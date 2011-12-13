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
	restartAll
}

keystoneOnly () {
	installKeystone
	initKeystone
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

compute () {
	installBase
	installCompute
	restartAll
}
