const setup = require('./setup.js');
const contract = setup.contractDragonKitty;

if (process.argv.length < 4) {
	console.error("Missing kittyId");
	process.exit();
}

var accountIndex = 0;
if (process.argv.length >= 5) {
	accountIndex = parseInt(process.argv[4], 10);
	console.error("Using account index:", accountIndex);
}

var _kittyId = parseInt(process.argv[3], 10);

start();

async function start(){
	let owner = await setup.getAccount(accountIndex);
	console.log("Sacrifice kitten:", _kittyId, "by", owner);
	let response = await contract.methods.sacrifice(_kittyId).send({from:owner});
	setup.consoleEvents(response);
	process.exit();
}
