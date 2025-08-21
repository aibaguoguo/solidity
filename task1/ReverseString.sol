// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

/**
 * 反转一个字符串。输入 "abcde"，输出 "edcba"
 */
contract ReverseString {
    function reverse(string memory str) public pure  returns(string memory) {
        bytes memory strBytes = bytes(str);
        for (uint i=0; i < strBytes.length / 2; i++) {
            bytes1 temp = strBytes[i];
            strBytes[i] = strBytes[strBytes.length - 1 - i];
            strBytes[strBytes.length - 1 - i] = temp;

        }
        return string(strBytes);
    }
}
