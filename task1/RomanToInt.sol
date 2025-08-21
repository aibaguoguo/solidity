// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
/**
 * 罗马数字转数整数
 * https://leetcode.cn/problems/integer-to-roman/description/
 */
contract RomanToInt{
    mapping(bytes1 => int) private  map;

    constructor(){
        map["I"]=1;
        map["V"]=5;
        map["X"]=10;
        map["L"]=50;
        map["C"]=100;
        map["D"]=500;
        map["M"]=1000;
    }

    function romanToInt(string memory s) public view returns(int){
        bytes memory strs = bytes(s);
        int res = 0;
        for(uint i=0;i<strs.length;i++){
            int value = map[strs[i]];
            if(i<strs.length-1&&value < map[strs[i+1]]){
                res -= value;
            }else{
                res += value;
            }
        }
        return res;
    }
}