/* global artifacts module */

const WrappedCK = artifacts.require('WrappedCK');

// This is the cheshire network address only
const kittyCoreAddress = "0xa751b62893867d0608a2ada5d17d0c43e3433040";

module.exports = async (deployer, network, accounts) => {
	if (network !== 'mainnet' && network !== 'rinkeby') {
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
