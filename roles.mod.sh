controller () {	
	installBase
    installController
    initDatabase
	network
    volume
    horizonOnly
    keystoneOnly
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
