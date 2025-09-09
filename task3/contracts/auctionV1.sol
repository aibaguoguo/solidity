// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
// @title 拍卖合约
// @dev 允许用户在拍卖合约中启动拍卖、竞价和结束拍卖
// @version 1.0 基础版 只支持原生eth参与竞价 不可升级
contract AuctionV1 {

    //合约部署者
    address private owner;
    // //拍卖持续时间 1个小时
    // uint256 private constant AUCTION_DURATION = 1 hours;
    //拍卖持续1分钟
    uint256 private constant AUCTION_DURATION = 10 seconds;
    //当前拍卖id
    uint256 private currentAuctionId;
    //拍卖信息
    mapping(uint256 => AuctionInfo) private auctions;
    //拍卖状态
    enum AuctionStatus {
        NotStarted,
        Started,
        Ended
    }
    struct AuctionInfo {
        address seller;//卖家
        address nftAddress;
        uint256 tokenId;
        uint256 startingPrice;
        uint256 endTime;
        address highestBidder;//当前最高 竞价人
        uint256 highestBid;//当前最高 竞价
        AuctionStatus status;//拍卖状态
    }
    constructor() {
        owner = msg.sender;
    }

    //启动拍卖
    function startAuction(address _nftAddress,uint256 _tokenId,uint256 _startingPrice) public {
        // require(msg.sender == owner, "Only owner can start auction");
        //判断拍卖是否存在
        require(auctions[currentAuctionId].status == AuctionStatus.NotStarted, "Auction already started");

        // 1. 检查地址是否是合约（可选，但推荐）
        if (_nftAddress.code.length == 0) {
            revert("The provided address is not a contract");
        }

        // 2. 检查合约是否支持 IERC721 接口
        try IERC165(_nftAddress).supportsInterface(type(IERC721).interfaceId) returns (bool isERC721) {
            if (!isERC721) {
                revert("The contract does not support ERC721 interface");
            }
        } catch {
            revert("Querying ERC721 interface support failed");
        }

        // 检查用户是否是NFT的所有者
        require(IERC721(_nftAddress).ownerOf(_tokenId) == address(msg.sender), "You are not the owner of this NFT");
        // 检查NFT是否已经被拍卖
        require(auctions[currentAuctionId].nftAddress == address(0), "NFT already auctioned");
        
        // 检查用户是否已经授权合约转移NFT
        require(
            IERC721(_nftAddress).isApprovedForAll(msg.sender, address(this)) || 
            IERC721(_nftAddress).getApproved(_tokenId) == address(this), 
            "Please approve the NFT for transfer first"
        );
        
        //创建拍卖
        auctions[currentAuctionId] = AuctionInfo({
            seller: msg.sender,
            nftAddress: _nftAddress,
            tokenId: _tokenId,
            startingPrice: _startingPrice,
            endTime: block.timestamp + AUCTION_DURATION,
            highestBidder: address(0),
            highestBid: 0,
            status: AuctionStatus.Started
        });
        //增加拍卖id
        currentAuctionId++;
    }

    //竞价
    function bid(uint256 _auctionId) public payable {
        //获取拍卖信息
        AuctionInfo storage auction = auctions[_auctionId];
        //判断拍卖是否结束
        require(block.timestamp < auction.endTime, "Auction ended");
        //判断竞价是否足够
        require(msg.value > auction.highestBid, "Bid not high enough");
        //判断是否是第一个竞价
        if (auction.highestBidder != address(0)) {
            //退还上一个竞价人
            payable(auction.highestBidder).transfer(auction.highestBid);
        }
        //更新竞价信息
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
    }

    //结束拍卖
    function endAuction(uint256 _auctionId) public {
        //获取拍卖信息
        AuctionInfo storage auction = auctions[_auctionId];
        //判断拍卖是否结束
        require(block.timestamp > auction.endTime, "Auction not ended");
        //判断拍卖状态
        require(auction.status == AuctionStatus.Started, "Auction not started");
        //合约部署者才能结束拍卖
        require(msg.sender == owner, "Only owner can end auction");
        //更新拍卖状态
        auction.status = AuctionStatus.Ended;
        //判断是否有竞价
        if (auction.highestBidder != address(0)) {
            // Transfer the NFT to the highest bidder
            IERC721(auction.nftAddress).transferFrom(auction.seller, auction.highestBidder, auction.tokenId);
            //提现竞价到卖家
            payable(auction.seller).transfer(auction.highestBid);
        }

    }

    //获取当前拍卖id
    function getCurrentAuctionId() public view returns (uint256) {
        return currentAuctionId;
    }
    
    //获取拍卖信息
    function getAuctionInfo(uint256 _auctionId) public view returns (AuctionInfo memory) {
        return auctions[_auctionId];
    }
}