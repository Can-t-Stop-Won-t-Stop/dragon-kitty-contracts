const setup = require('./setup.js');

if (process.argv.length < 4) {
	console.error("Missing address");
	process.exit();
}

var addressTo = process.argv[3];

start();

async function start(){
	let response = await setup.web3.eth.getBalance(addressTo).call();
	console.log("ETH Balance of", addressTo, "is", response);
	process.exit();
}
