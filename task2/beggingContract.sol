// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
contract BeggingContract{

    mapping(address=>uint) private _donates;
    Donator[] private topThreeDonators;
    address private owner;
    uint256 constant TIMEZONE_OFFSET = 8 hours;//+8区

    error TransferFailed(address from,  uint256 amount, string reason);
    event Donation(address from,uint256 amount);

    constructor(){
        owner = msg.sender;
    }
    //捐赠包装
    struct Donator{
        address ad;
        uint256 amount;
    }

    //校验合约拥有者
    modifier onlyOwner {
        require(msg.sender == owner, "Not owner");
        _;
    }

    //时间校验,只支持北京时间上午[9,12)之间才能捐赠
    modifier time {
        require(getCurrentBeijingHour()>=9, "Not donation time");
        require(getCurrentBeijingHour()<12, "Not donation time");
        _;
    }

    /**
    *接受eth转账
    */
    receive() external payable {}

    //提现
    function withdraw() public onlyOwner{
        uint256 balance = address(this).balance; //获取合约地址的余额
        if(balance > 0){
            payable(msg.sender).transfer(balance);
        }
    }

    //记录捐赠者并接受转账
    function donate() public time payable returns(bool){
        require(msg.value > 0, "Donation amount must be greater than 0");
        _donates[msg.sender] += msg.value;
        //判断是否转账成功,耗费更多gas
        (bool success, ) = address(this).call{value:msg.value}("");
        if(!success){
            revert TransferFailed(msg.sender, msg.value, "transfer failed");
        }
        //更新top3
        updateTopThreeDonators(Donator(msg.sender, msg.value));
        // sort(); 可以自定义排序规则
        emit Donation(msg.sender, msg.value);
        return true;
    }

    function getTopThreeDonators() public view  returns(Donator[] memory){
        return topThreeDonators;
    }

    /**
     * 更新top3
     */
    function updateTopThreeDonators(Donator memory donator) private {

        for(uint i=0; i<topThreeDonators.length; i++){
            //已存在直接更新
            if(donator.ad == topThreeDonators[i].ad){
                topThreeDonators[i].amount += donator.amount;
                return;
            }
            //更新排行榜
            if(topThreeDonators.length == 3 && donator.amount > topThreeDonators[i].amount){
                topThreeDonators[i] = donator;
                return;
            }
        }
        //排行榜不足3,直接插入
        topThreeDonators.push(donator);
    }



    function getDonation(address donator) public view returns(uint){
        return _donates[donator];
    }

    /**
     * 当前合约余额
     */
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }


    function getCurrentBeijingHour() public view returns(uint256) {
        return ((block.timestamp + TIMEZONE_OFFSET) / 3600) % 24;
    }

}