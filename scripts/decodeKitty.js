const setup = require('./setup.js');
const contract = setup.contractDragonKitty;

if (process.argv.length < 4) {
	console.error("Missing kittyId");
	process.exit();
}

var _kittyId = parseInt(process.argv[3], 10);

start();

async function start(){
	console.log("Kitty", _kittyId, "has the following stats:");
	let response = await contract.methods.decodeKitty(_kittyId).call();
	console.log(response);
	process.exit();
}
