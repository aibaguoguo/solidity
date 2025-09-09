require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  namedAccounts: {
    deployer: 0,
    user1: 1,
    user2: 2,
    user3: 3,
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      allowUnlimitedContractSize: true,
    },
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.SEPOLIA_URL_KEY}`,
      accounts:{
        aiba: [process.env.SEPOLIA_ACCOUNTS_KEY],
        joy: [process.env.SEPOLIA_ACCOUNTS_KEY2],
      }
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  sourcify: {
    enabled: true,
  },
};
