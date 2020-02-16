const setup = require('./setup.js');
const contract = setup.contractDragonKitty;

var index = (process.argv.length >= 4) ? process.argv[3] : 0;

start();

async function start(){
	let response = await contract.methods.history(index).call();
	console.log(response);
	process.exit();
}
