const setup = require('./setup.js');
const contract = setup.contract;

start();

async function start(){
	console.log("Retrieving . . .")
	let owner = await setup.getOwner();
	let response = await contract.methods.changeOwner(owner).send({"from":owner})
	.on('confirmation', (confirmation, receipt) => {
		console.log(receipt);
		process.exit();
	})
	.on('error', () => {
		console.error("Error:", arguments);
		process.exit();
	});
}
