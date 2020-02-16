const setup = require('./setup.js');
const contract = setup.contractDai;

if (process.argv.length < 4) {
	console.error("Missing address");
	process.exit();
}

var addressTo = process.argv[3];

start();

async function start(){
	let response = await contract.methods.balanceOf(addressTo).call();
	console.log("Balance of", addressTo, "is", response);
	process.exit();
}
