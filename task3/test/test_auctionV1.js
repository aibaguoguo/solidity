const { ethers } = require("hardhat");
const { expect } = require("chai"); // 添加 chai 断言库
//获取deployments
const { deployments } = require("hardhat");

describe("正常拍卖流程", function () {
    let owner, addr1, addr2, nft,tokenId,nftAddress,auctionAddress;

    // 在 before 钩子中初始化测试环境
    before(async function () {
        // 获取账号
        [owner, addr1, addr2] = await ethers.getSigners();
        console.log("owner:", owner.address);
        console.log("addr1:", addr1.address);
        console.log("addr2:", addr2.address);

        // 部署nft合约
        const nftFactory = await ethers.getContractFactory("MyNFT");
        nft = await nftFactory.deploy();
        nft.waitForDeployment();
        nftAddress = await nft.getAddress();
        console.log("MyNFT deployed to:", nftAddress);

        //铸造NFT
        const tx = await nft.awardItem(owner.address, "my nft");
        const receipt = await tx.wait();
        // 使用辅助函数查找Transfer事件
        tokenId = findEvent(receipt, "Transfer",nft);
        console.log("铸造的tokenId:", tokenId);        
        // 验证逻辑
        expect(await nft.ownerOf(tokenId)).to.equal(owner.address);

        //部署auctionV1合约
        const auctionFactory = await ethers.getContractFactory("AuctionV1");
        auction = await auctionFactory.deploy();
        await auction.waitForDeployment();
        auctionAddress = await auction.getAddress();
        console.log("AuctionV1 deployed to:", auctionAddress);
    });

    //部署auctionV1合约
    it("测试未授权启动拍卖", async function () {
        //启动拍卖
        expect( auction.startAuction(nftAddress, tokenId, 1))
        .to.be.revertedWith("Please approve the NFT for transfer first");
    });

    it("测试授权启动拍卖成功", async function () {
        //授权拍卖合约
        await nft.approve(auctionAddress, tokenId);
        //启动拍卖
        await auction.startAuction(nftAddress, tokenId, 1);

        //验证拍卖状态
        let auctionInfo = await auction.getAuctionInfo(0);
        expect(auctionInfo.status).to.equal(1);
        
        //使用addr1竞价
        const bidder1 = await auction.connect(addr1);
        const bidAmount = ethers.parseEther("3");
        await bidder1.bid(0,{value:bidAmount});
        //验证addr1竞价成功
        auctionInfo = await auction.getAuctionInfo(0);

        //打印拍卖合约的余额
        console.log("bidder1拍卖成功后合约的余额:",ethers.formatEther(await ethers.provider.getBalance(auctionAddress)));
        expect(auctionInfo.highestBid).to.equal(bidAmount);
        expect(auctionInfo.highestBidder).to.equal(addr1.address);

        //使用addr2竞价
        const bidder2 = await auction.connect(addr2);
        const bidAmount2 = ethers.parseEther("7");
        await bidder2.bid(0,{value:bidAmount2});
        //验证addr2竞价成功
        auctionInfo = await auction.getAuctionInfo(0);
        console.log("bidder2拍卖成功后合约的余额:",ethers.formatEther(await ethers.provider.getBalance(auctionAddress)));

        expect(auctionInfo.highestBid).to.equal(bidAmount2);
        expect(auctionInfo.highestBidder).to.equal(addr2.address);
        
        
        //等待10s
        await new Promise((resolve) => setTimeout(resolve, 10*1000));
        //结束拍卖
        await auction.endAuction(0);
        //验证拍卖状态
        auctionInfo = await auction.getAuctionInfo(0);
        expect(auctionInfo.status).to.equal(2);
        //验证addr2获得nft
        expect(await nft.ownerOf(tokenId)).to.equal(addr2.address);
        
    });
    
});










function findEvent(receipt, eventName,nft) {
    // 安全地查找Transfer事件
        const transferEvent = receipt.events?.find(e => e.event === "Transfer");
        let tokenId;
        if (!transferEvent) {
            // 尝试备选方法：使用合约接口解析
            const iface = nft.interface;
            const transferEvents = receipt.logs
                .map(log => {
                    try {
                        return iface.parseLog(log);
                    } catch (e) {
                        return null;
                    }
                })
                .filter(event => event?.name === eventName);
            
            if (transferEvents.length === 0) {
                throw new Error("Transfer event not found in any form");
            }
            
            tokenId = transferEvents[0].args.tokenId;
            console.log("铸造的tokenId (备选方法):", tokenId.toString());
        } else {
            tokenId = transferEvent.args.tokenId;
            console.log("铸造的tokenId:", tokenId.toString());
        }
        return tokenId;
}