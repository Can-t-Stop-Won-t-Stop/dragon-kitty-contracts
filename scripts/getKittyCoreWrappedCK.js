const setup = require('./setup.js');
const contract = setup.contractWrappedCK;

start();

async function start(){
  console.log("Retrieving . . .")
  let response = await contract.methods.kittyCoreAddress().call();
  console.log(response);
  process.exit();
}
