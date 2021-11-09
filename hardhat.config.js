require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  defaultNetwork: "matic",
  networks: {
    hardhat: {
    },
    matic: {
      url: "https://speedy-nodes-nyc.moralis.io/8475903b7136601f734838fe/polygon/mainnet/archive",
      accounts: [''],
      gasPrice: 1200000000000
    },
    ropsten: {
      url: "https://speedy-nodes-nyc.moralis.io/8475903b7136601f734838fe/eth/ropsten",
      accounts: ['']
    }
  },
  solidity: {
    version: "0.8.0",
    // settings: {
    //   optimizer: {
    //     enabled: true,
    //     runs: 200
    //   }
    // }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "V91J1BDBH6W5RT7K35SQFEKEB6UW6SIF5P"
  }
}
