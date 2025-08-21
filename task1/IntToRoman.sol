// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * 实现整数转罗马数字
 * 题目描述在 https://leetcode.cn/problems/roman-to-integer/description/3.
 */
contract IntToRoman {

    function intToRoman(uint16 num) public pure returns(string memory) {
        uint16[13] memory values = [1000,900,500,400,100,90,50,40,10,9,5,4,1];
        string memory roman = "";
        for (uint i = 0; i < values.length; i++) {
            uint16 value = values[i];
            while (num >= value) {
                roman = string(abi.encodePacked(roman, getRomanByInt(value)));
                num -= value;
            }
        }
        return "";
    }

    function getRomanByInt(uint16 num) private pure returns (string memory){
        if(num ==1000){
            return "M";
        }
        if(num ==900){
            return "CM";
        }
        if(num ==500){
            return "D";
        }
        if(num ==400){
            return "CD";
        }
        if(num ==100){
            return "C";
        }
        if(num ==90){
            return "XC";
        }
        if(num ==50){
            return "L";
        }
        if(num ==40){
            return "XL";
        }
        if(num ==10){
            return "X";
        }
        if(num ==9){
            return "IX";
        }
        if(num ==5){
            return "V";
        }
        if(num ==4){
            return "IV";
        }
        if(num ==1){
            return "I";
        }
        return "";
    }


}