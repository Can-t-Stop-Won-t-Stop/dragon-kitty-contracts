/* global artifacts module */

//const DragonKitty = artifacts.require('DragonKitty');

module.exports = async (deployer, network, accounts) => {
	if (network === 'rinkeby') {
		// Do nothing
	}

	/*
	await deployer.deploy(
		DragonKitty,
		proxyRegistryAddress
	);

	const contract = await DragonKitty.deployed();
	const ownerFromContract = await contract.owner();

	let tx = await contract.create(tokenQuantity, tokenUri, {from: ownerFromContract});
	*/
};
