/* global artifacts module */

const WrappedCK = artifacts.require('WrappedCK');
const DragonKitty = artifacts.require('DragonKitty');

// mainnet addresses
var kittyCoreAddress = "0xa751b62893867d0608a2ada5d17d0c43e3433040";
var wrappedCKAddress = "0x5867c89b5923662012b33E500c3aB9E09de3e272";

module.exports = async (deployer, network, accounts) => {
	if (network === 'rinkeby') {
		// Do nothing
		kittyCoreAddress = "0x16baf0de678e52367adc69fd067e5edd1d33e3bf";
		//wrappedCKAddress = "";
	} else if (network !== 'mainnet') {
		const wrappedCKContract = await WrappedCK.deployed();
		wrappedCKAddress = wrappedCKContract.address;
	}

	await deployer.deploy(
		DragonKitty,
		kittyCoreAddress,
		wrappedCKAddress
	);

	/*
	const contract = await DragonKitty.deployed();
	const ownerFromContract = await contract.owner();

	let tx = await contract.create(tokenQuantity, tokenUri, {from: ownerFromContract});
	*/
};
