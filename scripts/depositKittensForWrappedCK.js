const setup = require('./setup.js');
const contract = setup.contractWrappedCK;

if (process.argv.length < 4) {
	console.error("Missing kittyIds");
	process.exit();
}

var _kittyIds = [];
for (let i = 3; i <= process.argv.length - 1; i++) {
	_kittyIds.push(parseInt(process.argv[i], 10));
}

start();

async function start(){
	let owner = await setup.getOwner();
	console.log("Depositing kittens:", _kittyIds, "for", owner);
	let response = await contract.methods.depositKittiesAndMintTokens(_kittyIds).send({"from":owner})
	.on('confirmation', (confirmation, receipt) => {
		console.log(receipt);
		process.exit();
	})
	.on('error', () => {
		console.error("Error:", arguments);
		process.exit();
	});
}
