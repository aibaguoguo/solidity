// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * 合并两个有序数组
 */
contract MergeSortedArray{
    function mergeSortedArray(int[] memory nums1,int[] memory nums2) public pure returns(int[] memory){
        int[] memory res = new int[](nums1.length+nums2.length);
        uint i = 0;
        uint j = 0;
        while(i<nums1.length&&j<nums2.length){
            if(nums1[i]<=nums2[j]){
                res[i+j] = nums1[i];
                i++;
                continue;
            }else{
                res[i+j] = nums2[j];
                j++;
                continue;
            }

        }

        if(i == nums1.length){
            for(;j<nums2.length;j++){
                res[i+j] = nums2[j];
            }
        }

        if(j == nums2.length){
            for(;i<nums1.length;i++){
                res[i+j] = nums1[i];
            }
        }

        return res;
    }
}