const setup = require('./setup.js');
const contract = setup.contractDragonKitty;

if (process.argv.length < 4) {
	console.error("Missing kittyId");
	process.exit();
}
var _kittyId = process.argv[3];

var accountIndex = 0;
if (process.argv.length >= 5) {
	accountIndex = parseInt(process.argv[4], 10);
	console.error("Using account index:", accountIndex);
}

var value = 0;
if (process.argv.length >= 6) {
	value = process.argv[5];
	console.error("Sending ETH value:", value);
}

var dai      = (process.argv.length >= 7) ? process.argv[6] : 0;
var chai     = (process.argv.length >= 8) ? parseInt(process.argv[7], 10) : 0;
var daiquiri = (process.argv.length >= 9) ? parseInt(process.argv[8], 10) : 0;
var daisake  = (process.argv.length >= 10) ? parseInt(process.argv[9], 10) : 0;

start();

async function start(){
	let owner = await setup.getAccount(accountIndex);
	console.log("Sacrifice kitten:", _kittyId, "by", owner);
	let response = await contract.methods.sacrifice(
		_kittyId,
		chai,
		daiquiri,
		daisake,
		dai
	).send({from:owner, value:value});
	setup.consoleEvents(response);
	process.exit();
}
