// @dev 升级合约
const { ethers, upgrades } = require("hardhat");

const fs = require("fs");
const path = require("path");
const { tags } = require("./1_deploy_autction");
const { log } = require("console");
module.exports = async function () {
    const AuctionV3 = await ethers.getContractFactory("AuctionV3");
    const {save} = deployments;
    //从.cache目录下读取代理合约地址
    const storePath = path.resolve(__dirname, "./.cache/proxyNftAuction.json");
    const {proxyAddress,implementationAddress,abi} = JSON.parse(fs.readFileSync(storePath, "utf8"));
    console.log("proxyAddress:",proxyAddress);
    console.log("old implementationAddress:",implementationAddress);

    const auctionV3 = await upgrades.upgradeProxy(proxyAddress, AuctionV3);
    await auctionV3.waitForDeployment();
    const newImplementationAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
    console.log("new implementationAddress:",newImplementationAddress);
    console.log("AuctionV3 合约已升级:", await auctionV3.getAddress());
    //打印V3的版本
    console.log("AuctionV3 合约版本:", await auctionV3.version());
    // 获取新合约的 ABI
    const newAbi = AuctionV3.interface.format("json");
    console.log("say hello:", await auctionV3.sayHello());
    
    await save("AuctionV3",{
        abi:newAbi,
        address: proxyAddress,
    })

    console.log("AuctionV3 合约版本:", await auctionV3.version());
    console.log("say hello:", await auctionV3.sayHello());
}
module.exports.tags = ["AuctionV3"]
