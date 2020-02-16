const setup = require('./setup.js');
const contract = setup.contractKittyCore;

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
	console.log("Approve kitten:", _kittyId, "for", owner);
	let response = await contract.methods.approve(setup.addressDragonKitty, _kittyId).send({from:owner});
	setup.consoleEvents(response);
	process.exit();
}
