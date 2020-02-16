const fs = require('fs');
const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');

const infura_key = fs.readFileSync(__dirname + "/../.infura").toString().trim();

let environment = process.argv[2], network_id, endpoint, private_key;

let accounts = ["0x7bc56a099a78d79deba210208ecf214c17e4a913b417dbf854b57edd317eb92f","0x130bac243499b440aeeaba88e14a6dd1e2d17c82a85ba928aeed354699fbd795","0xa9d33ee7ff5359209e6b27a0625a242767ba18218f598ebc2f15733420ad6798","0x0881c14ffcf978b43eedf57a49d3bcecbbbbb317f6b1098f2d5996b7702744b3","0xca74aa1b79d87563e38d5ff0384ad678c7b176bcd7caa2c503bcfd0004e6567d","0x99995bdd84af8d1cb2548808d3f2c4ec8dc1b79577856c064f2bf346aeaad2cd","0xe17ad3108883ae14866f3598e65d4d27726efb990f381254d1b909ea783502e4","0x44d6627a1e7dcb0d0c353a067ad901449d756c97b38b4feb99c0e752fbbb80d1","0x6e77cfded732de6d423abcaccc45ee8c4bdc2eb3c0c47938acb386ac17c496b8"];

let contract_addressCK = "0xa751b62893867d0608a2ada5d17d0c43e3433040";

if (environment === 'rinkeby') {
	network_id = '4';
	endpoint = 'https://rinkeby.infura.io/v3/' + infura_key;
	private_key = fs.readFileSync(__dirname + "/../.secret.rinkeby.key").toString().trim();
	contract_addressCK = "0x16baf0de678e52367adc69fd067e5edd1d33e3bf";

	// 0x4cea0E5c93404027888e392A82d4d9829EF21604
	accounts = [private_key, "0x1612CD25A496F24198836B5113C8C4382AE8D3BA7B09E1D3DB401697940D60EF"].concat(accounts);

} else if (environment === 'testnet') {
	// Iterate over networks, get the last testnet-looking one
	const getNetworkJsonString = fs.readFileSync(__dirname + "/../build/contracts/WrappedCK.json").toString().trim();
	const getNetworkJson = JSON.parse(getNetworkJsonString);
	const networkIds = Object.keys(getNetworkJson.networks);
	for (let idx = 0; idx < networkIds.length; idx++)
		if (networkIds[idx] != "1" && networkIds[idx] != "4") network_id = networkIds[idx];

	endpoint = 'http://localhost:8546';
	private_key = fs.readFileSync(__dirname + "/../.secret.testnet.key").toString().trim();
	contract_addressCK = "0xa751b62893867d0608a2ada5d17d0c43e3433040";

	accounts = [private_key, "0x1612CD25A496F24198836B5113C8C4382AE8D3BA7B09E1D3DB401697940D60EF"].concat(accounts);
} else if (environment === 'mainnet') {
	network_id = '1';
	endpoint = 'https://mainnet.infura.io/v3/' + infura_key;
	private_key = fs.readFileSync(__dirname + "/../.secret.mainnet.key").toString().trim();
	contract_addressCK = "0xa751b62893867d0608a2ada5d17d0c43e3433040";

	accounts = [private_key, "0x1612CD25A496F24198836B5113C8C4382AE8D3BA7B09E1D3DB401697940D60EF"].concat(accounts);
} else {
	console.error("Invalid environment:", environment);
	process.exit();
}

const provider = new HDWalletProvider(accounts, endpoint, 0, accounts.length);

const abiCK = [{"constant": true,"inputs": [{"name": "_interfaceID","type": "bytes4"}],"name": "supportsInterface","outputs": [{"name": "","type": "bool"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "cfoAddress","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [{"name": "_tokenId","type": "uint256"},{"name": "_preferredTransport","type": "string"}],"name": "tokenMetadata","outputs": [{"name": "infoUrl","type": "string"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "promoCreatedCount","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "name","outputs": [{"name": "","type": "string"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_to","type": "address"},{"name": "_tokenId","type": "uint256"}],"name": "approve","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "ceoAddress","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "GEN0_STARTING_PRICE","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_address","type": "address"}],"name": "setSiringAuctionAddress","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "totalSupply","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "pregnantKitties","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [{"name": "_kittyId","type": "uint256"}],"name": "isPregnant","outputs": [{"name": "","type": "bool"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "GEN0_AUCTION_DURATION","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "siringAuction","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_from","type": "address"},{"name": "_to","type": "address"},{"name": "_tokenId","type": "uint256"}],"name": "transferFrom","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_address","type": "address"}],"name": "setGeneScienceAddress","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_newCEO","type": "address"}],"name": "setCEO","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_newCOO","type": "address"}],"name": "setCOO","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_kittyId","type": "uint256"},{"name": "_startingPrice","type": "uint256"},{"name": "_endingPrice","type": "uint256"},{"name": "_duration","type": "uint256"}],"name": "createSaleAuction","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [{"name": "","type": "uint256"}],"name": "sireAllowedToAddress","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [{"name": "_matronId","type": "uint256"},{"name": "_sireId","type": "uint256"}],"name": "canBreedWith","outputs": [{"name": "","type": "bool"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [{"name": "","type": "uint256"}],"name": "kittyIndexToApproved","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_kittyId","type": "uint256"},{"name": "_startingPrice","type": "uint256"},{"name": "_endingPrice","type": "uint256"},{"name": "_duration","type": "uint256"}],"name": "createSiringAuction","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "val","type": "uint256"}],"name": "setAutoBirthFee","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_addr","type": "address"},{"name": "_sireId","type": "uint256"}],"name": "approveSiring","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_newCFO","type": "address"}],"name": "setCFO","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_genes","type": "uint256"},{"name": "_owner","type": "address"}],"name": "createPromoKitty","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "secs","type": "uint256"}],"name": "setSecondsPerBlock","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "paused","outputs": [{"name": "","type": "bool"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [{"name": "_tokenId","type": "uint256"}],"name": "ownerOf","outputs": [{"name": "owner","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "GEN0_CREATION_LIMIT","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "newContractAddress","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_address","type": "address"}],"name": "setSaleAuctionAddress","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [{"name": "_owner","type": "address"}],"name": "balanceOf","outputs": [{"name": "count","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "secondsPerBlock","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [],"name": "pause","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [{"name": "_owner","type": "address"}],"name": "tokensOfOwner","outputs": [{"name": "ownerTokens","type": "uint256[]"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_matronId","type": "uint256"}],"name": "giveBirth","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [],"name": "withdrawAuctionBalances","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "symbol","outputs": [{"name": "","type": "string"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [{"name": "","type": "uint256"}],"name": "cooldowns","outputs": [{"name": "","type": "uint32"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [{"name": "","type": "uint256"}],"name": "kittyIndexToOwner","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_to","type": "address"},{"name": "_tokenId","type": "uint256"}],"name": "transfer","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "cooAddress","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "autoBirthFee","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "erc721Metadata","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_genes","type": "uint256"}],"name": "createGen0Auction","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [{"name": "_kittyId","type": "uint256"}],"name": "isReadyToBreed","outputs": [{"name": "","type": "bool"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "PROMO_CREATION_LIMIT","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_contractAddress","type": "address"}],"name": "setMetadataAddress","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "saleAuction","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_sireId","type": "uint256"},{"name": "_matronId","type": "uint256"}],"name": "bidOnSiringAuction","outputs": [],"payable": true,"stateMutability": "payable","type": "function"},{"constant": true,"inputs": [],"name": "gen0CreatedCount","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "geneScience","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_matronId","type": "uint256"},{"name": "_sireId","type": "uint256"}],"name": "breedWithAuto","outputs": [],"payable": true,"stateMutability": "payable","type": "function"},{"inputs": [],"payable": false,"stateMutability": "nonpayable","type": "constructor"},{"payable": true,"stateMutability": "payable","type": "fallback"},{"anonymous": false,"inputs": [{"indexed": false,"name": "owner","type": "address"},{"indexed": false,"name": "matronId","type": "uint256"},{"indexed": false,"name": "sireId","type": "uint256"},{"indexed": false,"name": "cooldownEndBlock","type": "uint256"}],"name": "Pregnant","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"name": "from","type": "address"},{"indexed": false,"name": "to","type": "address"},{"indexed": false,"name": "tokenId","type": "uint256"}],"name": "Transfer","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"name": "owner","type": "address"},{"indexed": false,"name": "approved","type": "address"},{"indexed": false,"name": "tokenId","type": "uint256"}],"name": "Approval","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"name": "owner","type": "address"},{"indexed": false,"name": "kittyId","type": "uint256"},{"indexed": false,"name": "matronId","type": "uint256"},{"indexed": false,"name": "sireId","type": "uint256"},{"indexed": false,"name": "genes","type": "uint256"}],"name": "Birth","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"name": "newContract","type": "address"}],"name": "ContractUpgrade","type": "event"},{"constant": false,"inputs": [{"name": "_v2Address","type": "address"}],"name": "setNewAddress","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [{"name": "_id","type": "uint256"}],"name": "getKitty","outputs": [{"name": "isGestating","type": "bool"},{"name": "isReady","type": "bool"},{"name": "cooldownIndex","type": "uint256"},{"name": "nextActionAt","type": "uint256"},{"name": "siringWithId","type": "uint256"},{"name": "birthTime","type": "uint256"},{"name": "matronId","type": "uint256"},{"name": "sireId","type": "uint256"},{"name": "generation","type": "uint256"},{"name": "genes","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [],"name": "unpause","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [],"name": "withdrawBalance","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_matronId","type": "uint256"},{"name": "_sireId","type": "uint256"},{"name": "_generation","type": "uint256"},{"name": "_genes","type": "uint256"},{"name": "_owner","type": "address"}],"name": "createKitty","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "nonpayable","type": "function"}];

const contractJsonWCKString = fs.readFileSync(__dirname + "/../build/contracts/WrappedCK.json").toString().trim();
const contractJsonWCK = JSON.parse(contractJsonWCKString);

const abiWCK = contractJsonWCK.abi;
const contract_addressWCK = contractJsonWCK.networks[network_id].address;
const addressWrappedCK = contract_addressWCK;

const contractJsonDKString = fs.readFileSync(__dirname + "/../build/contracts/DragonKitty.json").toString().trim();
const contractJsonDK = JSON.parse(contractJsonDKString);

const abiDK = contractJsonDK.abi;
const contract_addressDK = contractJsonDK.networks[network_id].address;
const addressDragonKitty = contract_addressDK;

const contractJsonDaiString = fs.readFileSync(__dirname + "/../build/contracts/Dai.json").toString().trim();
const contractJsonDai = JSON.parse(contractJsonDaiString);

const abiDai = contractJsonDai.abi;
const contract_addressDai = contractJsonDai.networks[network_id].address;
const addressDai = contract_addressDai;

const web3 = new Web3(provider);
const contractKittyCore = new web3.eth.Contract(abiCK, contract_addressCK);
const contractWrappedCK = new web3.eth.Contract(abiWCK, contract_addressWCK);
const contractDragonKitty = new web3.eth.Contract(abiDK, contract_addressDK);
const contractDai = new web3.eth.Contract(abiDai, contract_addressDai);

async function getOwner() {
	account = await web3.eth.getAccounts();
	return account[0];
}

async function getPlayer() {
	account = await web3.eth.getAccounts();
	return account[1];
}

async function getAccount(idx) {
	account = await web3.eth.getAccounts();
	return account[idx];
}

function consoleEvents(response) {
	if (response && response.events) {
		for (let eventId in response.events) {
			if (response.events.hasOwnProperty(eventId) && response.events[eventId].event) {
				console.log("Event:", response.events[eventId].event, response.events[eventId].returnValues);
			}
		}
	}
}

module.exports = {
	getOwner,
	getPlayer,
	getAccount,
	addressWrappedCK,
	addressDragonKitty,
	contractWrappedCK,
	contractKittyCore,
	contractDragonKitty,
	contractDai,
	consoleEvents
}
