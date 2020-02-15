# Kitties Versus Dragons, aka "Die Kitty Dai"

## Local System Installation

Pull down the `cheshire` repo to run a local instance of Cryptokitties with some helper scripts: https://github.com/endless-nameless-inc/cheshire

Run the installation for `cheshire`, then `yarn start`.

Pull down this repo, then:

```
npm install
truffle compile
truffle deploy --network cheshire
```

### Notice: Running a second time

When deploying to `cheshire`, the network ID can change. In this case, you may need to `rm -rf build` so that the test scripts identify the correct testnet network ID automatically.

### Testing

You need to provide keys for each network type:

```
.testnet.secret.key # for the local cheshire network
.rinkeby.secret.key
.mainnet.secret.key
```

There are a bunch of scripts in the `scripts` directory, the format to run them is:

```
node scripts/[script.js] [testnet/rinkeby/mainnet] [any arguments]
```

#### Getting Kitties

By default, all of the kitties you can mint yourself on the `cheshire` repo go to the first address in the `accounts` object, aka the `owner`. You can mint test kitties through `cheshire` by going to that repo and running `yarn run script ./scripts/import-bug-cat.js`

#### Sending Kitties to the Contract

Like with WrappedCK, you **need** to `approve` each individual Cryptokitty transfer by approving the `DragonKitty` contract. There's a script that automates this for the `owner` account:

`node scripts/approveCKDragonKitty.js [testnet/rinkeby/mainnet] [kittyId]`

Example: `node scripts/approveCKDragonKitty.js testnet 3`

Then you can sacrifice your kitties to the boss using:

`node scripts/sacrifice.js [testnet/rinkeby/mainnet] [kittyId]`
