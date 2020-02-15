const setup = require('./setup.js');
const contract = setup.contractDragonKitty;

if (process.argv.length < 4) {
	console.error("Missing kittyId");
	process.exit();
}

var _kittyId = parseInt(process.argv[3], 10);

start();

async function start(){
	let owner = await setup.getOwner();
	console.log("Sacrifice kitten:", _kittyId);
	let response = await contract.methods.sacrifice(_kittyId).send({from:owner});
	console.log(response);
	process.exit();
}
