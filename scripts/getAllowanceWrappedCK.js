const setup = require('./setup.js');
const contract = setup.contractWrappedCK;

if (process.argv.length < 4) {
	console.error("Missing `from` address");
	process.exit();
}

if (process.argv.length < 5) {
	console.error("Missing `to` address");
	process.exit();
}

var _addressFrom = process.argv[3];
var _addressTo = process.argv[4];

start();

async function start(){
	let response = await contract.methods.allowance(_addressFrom, _addressTo).call();
	console.log("Approved amount of transfer:", response, "to", _addressTo, "from", _addressFrom);
	process.exit();
}
