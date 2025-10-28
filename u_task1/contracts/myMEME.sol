// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
// import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
// import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract MyMEME is ERC20, Ownable {
    using Math for uint256;

    //每日交易上限 总供应的1%
    uint256 public maxDailyTransfer = totalSupply().mulDiv(1, 100);
    struct DailyTrans{
        uint256 dailySumAmount;//当日交易总额
        uint256 lastTransTime;//最后交易时间
    }
    //当日交易量记录
    mapping(address => DailyTrans) public dailyTransferAmount;
    //基础交易税 3% 其中 1%流动性 2%社区运营
    uint256 public constant LIQUIDITY_TAX_RATE = 1; // 1%
    uint256 public constant COMMUNITY_TAX_RATE = 2; // 2%
    //税费白名单
    mapping(address => bool) public taxWhitelist;
    
    //流动性账户地址
    address public liquidityAddress;
     //社区运营账户地址
    address public communityAddress;

    //构造函数
    constructor(address _liquidityAddress, address _communityAddress) ERC20("QuickToken", "QKQK") Ownable(msg.sender) {
        _mint(msg.sender, totalSupply());
        liquidityAddress = _liquidityAddress;
        communityAddress = _communityAddress;
    }

    //转账操作
    function transfer(address _to, uint256 _amount) public override returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_amount <= balanceOf(msg.sender), "Insufficient balance");
        if (block.timestamp > dailyTransferAmount[msg.sender].lastTransTime + 1 days ) {
            dailyTransferAmount[msg.sender].dailySumAmount = 0;      
            dailyTransferAmount[msg.sender].lastTransTime = block.timestamp;     
        }

        dailyTransferAmount[msg.sender].dailySumAmount += _amount;
        require(dailyTransferAmount[msg.sender].dailySumAmount <= maxDailyTransfer, "Exceeded daily transfer limit");
        
        //如果不在白名单，计算税
        uint256 transferAmount = _amount;
        if (!taxWhitelist[msg.sender]) {
            uint256 liquidityTax = calculateLiquidityTax(_amount);
            uint256 communityTax = calculateCommunityTax(_amount);
            transferAmount = _amount - liquidityTax - communityTax;
            super._transfer(msg.sender, liquidityAddress, liquidityTax);
            emit Transfer(msg.sender, liquidityAddress, liquidityTax);
            super._transfer(msg.sender, communityAddress, communityTax);
            emit Transfer(msg.sender, communityAddress, communityTax);
        } 

        super._transfer(msg.sender, _to, transferAmount);
        emit Transfer(msg.sender, _to, transferAmount);
        return true;
    }

    //流动性税计算
    function calculateLiquidityTax(uint256 _amount) internal pure returns (uint256) {
        return _amount.mulDiv(LIQUIDITY_TAX_RATE, 100);
    }
    //社区运营税计算
    function calculateCommunityTax(uint256 _amount) internal pure returns (uint256) {
        return _amount.mulDiv(COMMUNITY_TAX_RATE, 100);
    }

    //精度
    function decimals() public pure override returns (uint8) {
        return 9;
    }

    //总供应量10兆
    function totalSupply() public pure override returns (uint256) {
        return 10e12 * 1e9;
    }

    //修改每日交易上限
    function setMaxDailyTransfer(uint256 _maxDailyTransfer) public onlyOwner {
        maxDailyTransfer = _maxDailyTransfer;
    }

    //修改流动性账户地址
    function setLiquidityAddress(address _liquidityAddress) public onlyOwner {
        liquidityAddress = _liquidityAddress;
    }
    //修改社区运营账户地址
    function setCommunityAddress(address _communityAddress) public onlyOwner {
        communityAddress = _communityAddress;
    }

    //添加到税费白名单
    function addToTaxWhitelist(address _account) public onlyOwner {
        taxWhitelist[_account] = true;
    }
    //从税费白名单移除
    function removeFromTaxWhitelist(address _account) public onlyOwner {
        taxWhitelist[_account] = false;
    }

    
}