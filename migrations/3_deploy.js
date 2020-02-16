/* global artifacts module */

const Dai = artifacts.require('Dai');
const WrappedCK = artifacts.require('WrappedCK');
const DragonKitty = artifacts.require('DragonKitty');

// mainnet addresses
var kittyCoreAddress = "0xa751b62893867d0608a2ada5d17d0c43e3433040";
var wrappedCKAddress = "0x5867c89b5923662012b33E500c3aB9E09de3e272";
var daiAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";

module.exports = async (deployer, network, accounts) => {
	if (network === 'rinkeby') {
		kittyCoreAddress = "0x16baf0de678e52367adc69fd067e5edd1d33e3bf";
		//daiAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
	}

	if (network !== 'mainnet') {
		const daiContract = await Dai.deployed();
		daiAddress = daiContract.address;

		const wrappedCKContract = await WrappedCK.deployed();
		wrappedCKAddress = wrappedCKContract.address;
	}

	await deployer.deploy(
		DragonKitty,
		kittyCoreAddress,
		wrappedCKAddress,
		daiAddress
	);

	/*
	const contract = await DragonKitty.deployed();
	const ownerFromContract = await contract.owner();

	let tx = await contract.create(tokenQuantity, tokenUri, {from: ownerFromContract});
	*/
};
