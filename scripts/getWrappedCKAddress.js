const setup = require('./setup.js');
const contract = setup.contractDragonKitty;

start();

async function start(){
  console.log("Retrieving . . .")
  let response = await contract.methods.wrappedCKAddress().call();
  console.log(response);
  process.exit();
}
