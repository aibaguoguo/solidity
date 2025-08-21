// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * 二分查找
 */
contract BinarySearch {
    function binarySearch(int[] memory nums, int target) public pure returns (uint256) {
        uint256 l = 0;
        uint256 r = nums.length;
        while (l<=r){
            uint256 mid = (r-l)/2 + l;
            int value = nums[mid];
            if(value ==target){
                return mid;
            }else if (value >target){
                r = mid -1;
            }else{
                l = mid +1;
            }
        }
        return 0;
    }
}
