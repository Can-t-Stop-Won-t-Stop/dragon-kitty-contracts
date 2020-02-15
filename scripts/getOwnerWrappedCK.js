const setup = require('./setup.js');
const contract = setup.contract;

start();

async function start(){
  console.log("Retrieving . . .")
  let response = await contract.methods.getOwner().call();
  console.log(response);
  process.exit();
}
