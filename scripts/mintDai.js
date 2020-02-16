const setup = require('./setup.js');
const contract = setup.contractDai;

if (process.argv.length < 4) {
	console.error("Missing address");
	process.exit();
}

var addressTo = process.argv[3];

var value = 0;
if (process.argv.length >= 5) {
	value = process.argv[4];
}

start();

async function start(){
	let owner = await setup.getOwner();
	console.log("Sending", value, "Dai to", addressTo);
	let response = await contract.methods.mint(addressTo, value).send({from:owner});
	setup.consoleEvents(response);
	process.exit();
}
