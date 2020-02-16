const setup = require('./setup.js');
const contract = setup.contractDai;

if (process.argv.length < 4) {
	console.error("Missing address");
	process.exit();
}

var addressFrom = process.argv[3];

var value = 0;
if (process.argv.length >= 5) {
	value = process.argv[4];
}

start();

async function start(){
	let owner = await setup.getOwner();
	console.log("Approving", value, "Dai from", addressFrom);
	let response = await contract.methods.approve(setup.addressDragonKitty, value).send({from:addressFrom});
	setup.consoleEvents(response);
	process.exit();
}
