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

if (process.argv.length < 6) {
	console.error("Missing amount in [unit] * 10^18");
	process.exit();
}

var _addressFrom = process.argv[3];
var _addressTo = process.argv[4];
var _WCKToken = process.argv[5];

start();

async function start(){
	console.log("Approve transfer:", _WCKToken, "to", _addressTo, "from", _addressFrom);
	let response = await contract.methods.approve(_addressTo, _WCKToken).send({from:_addressFrom});
	console.log(response);
	process.exit();
}
