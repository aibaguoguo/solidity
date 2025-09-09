// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//openzeppelin 合约升级
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
//导入chainlink
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// @title 拍卖合约
// @dev 允许用户在拍卖合约中启动拍卖、竞价和结束拍卖
// @version 4.0 可升级合约版 支持erc20和eth参与竞价 
contract AuctionV4 is Initializable{
    string public version ; // 添加版本标识
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
        uint256 startingPrice;//兑换成usd后的价格
        address payTokenAddress;//支付货币地址 x0eth 其他erc20
        uint256 endTime;
        address highestBidder;//当前最高 竞价人
        uint256 highestBid;//当前最高 竞价
        AuctionStatus status;//拍卖状态
    }

    //喂价信息
    mapping(address => AggregatorV3Interface) public priceFeeds;

    //设置喂价
    function setPriceFeed(address _tokenAddress, address _priceFeed) public {
        priceFeeds[_tokenAddress] = AggregatorV3Interface(_priceFeed);
    }
    
    //初始化
    function initialize() initializer public {
        owner = msg.sender;
    }

    //启动拍卖
    function startAuction(address _nftAddress,uint256 _tokenId,uint256 _startingPrice) public {
        // require(msg.sender == owner, "Only owner can start auction");
        //判断拍卖是否存在
        require(auctions[currentAuctionId].status == AuctionStatus.NotStarted, "Auction already started.");

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
            status: AuctionStatus.Started,
            payTokenAddress: address(0)
        });
        //增加拍卖id
        currentAuctionId++;
    }

    //竞价
    function bid(uint256 _auctionId,address _payTokenAddress,uint256 _amount) public payable {
        //获取拍卖信息
        AuctionInfo storage auction = auctions[_auctionId];
        //判断拍卖是否结束
        require(block.timestamp < auction.endTime, "Auction ended");


        //统一转换成美元
        uint256 _bidToUSD;
        if(_payTokenAddress == address(0)){
            //通过chainlink 将eth(msg.value) 兑换成usd
            _bidToUSD = convertToUSD(msg.value,address(0));
        }else{
            //通过chainlink 将erc20(_amount) 兑换成usd
            _bidToUSD = convertToUSD(_amount,_payTokenAddress);
        }

        require(_bidToUSD > convertToUSD(auction.highestBid, auction.payTokenAddress), "Bid not high enough");


        //erc20 支付
        if(_payTokenAddress != address(0)){
            //支付erc20到当前合约
            IERC20(_payTokenAddress).transferFrom(msg.sender, address(this), _amount);
        }

        //判断是否是第一个竞价
        if (auction.highestBidder != address(0)) {
            //退还上一个竞价人
            //如果是eth
            if(auction.payTokenAddress == address(0)){
                //退还eth
                payable(auction.highestBidder).transfer(auction.highestBid);
            }else{
                //退还erc20
                IERC20(auction.payTokenAddress).transfer(auction.highestBidder,auction.highestBid);
            }
           
        }
        //更新竞价信息
        auction.highestBidder = msg.sender;
        auction.highestBid = _payTokenAddress==address(0)?msg.value:_amount;
        auction.payTokenAddress = _payTokenAddress;
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
            if(auction.payTokenAddress == address(0)){
                //提现eth到卖家
                payable(auction.seller).transfer(auction.highestBid);
            }else{
                //提现erc20到卖家
                IERC20(auction.payTokenAddress).transfer(auction.seller,auction.highestBid);
            }
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

    //say hello
    function sayHello() public pure returns (string memory) {
        return "hello world";
    }

    //通过chainlink 转换
    function convertToUSD(uint256 _amount,address _tokenAddress) public view returns (uint256) {
        //通过chainlink 转换
        return _amount * uint256(getChainlinkDataFeedLatestAnswer(_tokenAddress));
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer(address _tokenAddress) public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = priceFeeds[_tokenAddress].latestRoundData();
        return answer;
    }
}