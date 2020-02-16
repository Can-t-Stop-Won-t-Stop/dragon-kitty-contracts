/* global artifacts module */

const Dai = artifacts.require('Dai');
const WrappedCK = artifacts.require('WrappedCK');

// This is the cheshire network address only
var kittyCoreAddress = "0xa751b62893867d0608a2ada5d17d0c43e3433040";

module.exports = async (deployer, network, accounts) => {
	if (network !== 'mainnet') {
		let networkId;
		if (network === 'rinkeby') {
			kittyCoreAddress = "0x16baf0de678e52367adc69fd067e5edd1d33e3bf";
			networkId = "4";
		} else {
			kittyCoreAddress = "0xa751b62893867d0608a2ada5d17d0c43e3433040";
			networkId = "10292020";
		}

		await deployer.deploy(
			Dai,
			networkId
		);

		await deployer.deploy(
			WrappedCK,
			kittyCoreAddress
		);

		/*
		const contract = await WrappedCK.deployed();
		const ownerFromContract = await contract.owner();

		let tx = await contract.create(tokenQuantity, tokenUri, {from: ownerFromContract});
		*/
	}
};
