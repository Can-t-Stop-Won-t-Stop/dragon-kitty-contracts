const fs = require('fs');
const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');

const contractJsonString = fs.readFileSync("../build/contracts/WrappedCK.json").toString().trim();
const contractJson = JSON.parse(contractJsonString);

const infura_key = fs.readFileSync("../.infura").toString().trim();

let environment = process.argv[2], network_id, endpoint, private_key;

if (environment === 'rinkeby') {
	network_id = '4';
	endpoint = 'https://rinkeby.infura.io/v3/' + infura_key;
	private_key = fs.readFileSync("../.secret.rinkeby.key").toString().trim();
} else if (environment === 'testnet') {
	network_id = '1581731654063';
	endpoint = 'http://localhost:8546';
	private_key = fs.readFileSync("../.secret.testnet.key").toString().trim();
} else if (environment === 'mainnet') {
	network_id = '1';
	endpoint = 'https://mainnet.infura.io/v3/' + infura_key;
	private_key = fs.readFileSync("../.secret.mainnet.key").toString().trim();
} else {
	console.error("Invalid environment:", environment);
	process.exit();
}

const provider = new HDWalletProvider(private_key, endpoint);
const abi = contractJson.abi;
const contract_address = contractJson.networks[network_id].address;

const web3 = new Web3(provider);
const contract = new web3.eth.Contract(abi, contract_address);

async function getOwner() {
	account = await web3.eth.getAccounts();
	return account[0];
}

module.exports = {
	abi,
	contract_address,
	endpoint,
	provider,
	getOwner,
	web3,
	contract
}
