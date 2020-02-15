const setup = require('./setup.js');
const contract = setup.contractDragonKitty;

start();

async function start(){
	let player = await setup.getPlayer();
	let response = await contract.methods.releasePrize().send({from:player});
	console.log(response);
	process.exit();
}
