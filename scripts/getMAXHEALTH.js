const setup = require('./setup.js');
const contract = setup.contractDragonKitty;

start();

async function start(){
	let response = await contract.methods.MAX_HEALTH().call();
	console.log("MAX_HEALTH:", response);
	process.exit();
}
