const { ethers } = require("hardhat");
const { expect } = require("chai"); // 添加 chai 断言库
//获取deployments
const { deployments } = require("hardhat");

describe("测试meme币", function () {
    it("测试账号", async function () {
        [owner, liquidityAddress, communityAddress,addr1,addr2] = await ethers.getSigners();
        console.log("owner:", owner.address);
        console.log("liquidityAddress:", liquidityAddress.address);
        console.log("communityAddress:", communityAddress.address);
        console.log("addr1:", addr1.address);
        console.log("addr2:", addr2.address);
    });

    it("测试部署", async function () {
        const factory = await ethers.getContractFactory("MyMEME");
        const meme = await factory.connect(owner).deploy(liquidityAddress.address, communityAddress.address);
        meme.waitForDeployment();
        console.log("meme deployed to:", await meme.getAddress());
        //打印合约owner
        console.log("contract owner:", await meme.owner());
        //增加白名单
        await meme.addToTaxWhitelist(owner.address);
        expect(await meme.taxWhitelist(owner.address)).to.equal(true);

        //使用owner测试转账
        await meme.connect(owner).transfer(addr1.address, 100000);
        console.log("communityAddress balance:", await meme.balanceOf(communityAddress.address));
        console.log("liquidityAddress balance:", await meme.balanceOf(liquidityAddress.address));
        //使用addr1测试转账
        await meme.connect(addr1).transfer(addr2.address, 50000);
        expect(await meme.balanceOf(addr2.address)).to.lessThan(50000);
        console.log("addr2 balance:", await meme.balanceOf(addr2.address));
        console.log("addr1 balance:", await meme.balanceOf(addr1.address));
        console.log("communityAddress balance2:", await meme.balanceOf(communityAddress.address));
        console.log("liquidityAddress balance2:", await meme.balanceOf(liquidityAddress.address));
    });
});