//获取部署和升级合约
const { deployments, upgrades ,ethers} = require("hardhat");
const fs = require("fs");
const path = require("path");
//部署合约
module.exports = async function ({ deployments }) {
    console.log(`[${network.name}] 开始部署...`);
    const {save} = deployments;
    //拿到合约工厂
    const AuctionV2 = await ethers.getContractFactory("AuctionV2");
    //通过代理部署合约
    const deployProxy = await upgrades.deployProxy(AuctionV2,[], {
        initializer: "initialize",
    });
    //等待合约部署完成
    await deployProxy.waitForDeployment();
    //打印代理合约地址
    const proxyAddress = await deployProxy.getAddress();
    console.log("AuctionV2 代理合约地址 deployed to:",proxyAddress);

    //原合约地址 0x5FbDB2315678afecb367f032d93F642f64180aa3
    const implementationAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
    console.log("AuctionV2 原合约地址 deployed to:",implementationAddress);

    //保存代理合约地址和原合约地址到.cache目录下
    const storePath = path.resolve(__dirname, "./.cache/proxyNftAuction.json");
    fs.writeFileSync(
        storePath,
        JSON.stringify({
            _version: "1.0",
            _network: network.name,
            _timestamp: Date.now(),
            proxyAddress,
            implementationAddress,
            abi: AuctionV2.interface.format("json"),
        })
    );

    await save("NftAuctionProxy", {
        abi: AuctionV2.interface.format("json"),
        address: proxyAddress,
    })

    const auctionV2 = await ethers.getContractAt("AuctionV2", proxyAddress);
    console.log("AuctionV2 合约版本:", await auctionV2.version());
}

module.exports.tags = ["AuctionV2"];
