const setup = require('./setup.js');
const contract = setup.contractKittyCore;

if (process.argv.length < 4) {
	console.error("Missing kittyId");
	process.exit();
}

var _kittyId = parseInt(process.argv[3], 10);

start();

async function start(){
	let owner = await setup.getOwner();
	console.log("Approve kitten:", _kittyId, "for", owner);
	let response = await contract.methods.approve(setup.addressDragonKitty, _kittyId).send({from:owner});
	console.log(response);
	process.exit();
}
