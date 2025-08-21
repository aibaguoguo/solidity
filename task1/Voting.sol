// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * 创建一个名为Voting的合约，包含以下功能：
    一个mapping来存储候选人的得票数
    一个vote函数，允许用户投票给某个候选人
    一个getVotes函数，返回某个候选人的得票数
    一个resetVotes函数，重置所有候选人的得票数
 */
contract Voting {
    mapping(string=>int32) vot;
    string[] keys;
    address owner;
    constructor(){
        owner = msg.sender;
    }

    function vote(string memory user) public {
        keys.push(user);
        vot[user]++;
    }

    function getVotes(string memory user) public view returns(int32) {
        return vot[user];
    }

    function resetVotes() public {
        require(msg.sender == owner,"no permission");
        for (uint256 i=0; i < keys.length; i++) {
            delete(vot[keys[i]]);
        }
    }
}
