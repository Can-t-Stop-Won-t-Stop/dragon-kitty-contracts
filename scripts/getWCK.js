const setup = require('./setup.js');
const contract = setup.contractWrappedCK;

if (process.argv.length < 4) {
	console.error("Missing address");
	process.exit();
}

var address = process.argv[3];

start();

async function start(){
	let response = await contract.methods.balanceOf(address).call();
	console.log("Amount of WCK tokens owned by", address, "is", response);
	process.exit();
}
