const setup = require('./setup.js');
const contract = setup.contractKittyCore;

if (process.argv.length < 4) {
	console.error("Missing kittyId");
	process.exit();
}

var _kittyId = parseInt(process.argv[3], 10);

start();

async function start(){
	let response = await contract.methods.kittyIndexToApproved(_kittyId).call();
	console.log("Approval of", _kittyId, "is", response);
	process.exit();
}
