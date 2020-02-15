const setup = require('./setup.js');
const contract = setup.contractDragonKitty;

start();

async function start(){
	let owner = await setup.getOwner();
	let response = await contract.methods.releasePrize().send({from:owner});
	console.log(response);
	process.exit();
}
