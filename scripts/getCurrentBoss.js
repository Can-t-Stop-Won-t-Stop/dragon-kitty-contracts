const setup = require('./setup.js');
const contract = setup.contractDragonKitty;

start();

async function start(){
	let response = await contract.methods.currentBoss().call();
	console.log(response);
	process.exit();
}
