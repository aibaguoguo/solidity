const { ethers } = require("hardhat");
const { deployments } = require("hardhat");
describe("测试升级", function () {
    it("验证升级合约", async function () {
        // 1. 加载部署状态
        await deployments.fixture(); // 加载所有部署
        
        // 2. 获取保存的合约信息
        const auctionDeployment = await deployments.get("AuctionV3");
        
        // 3. 创建合约实例
        auctionContract = await ethers.getContractAt(
            auctionDeployment.abi,
            auctionDeployment.address
        );
        console.log("AuctionV3 合约地址 deployed to:",await auctionContract.getAddress());
        //say hello
        console.log("say hello:", await auctionContract.sayHello());
        
    })
});