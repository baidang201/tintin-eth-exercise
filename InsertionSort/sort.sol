// SPDX-License-Identifier: APACHE
pragma solidity ^0.8.24;

contract Sort {
    function sort(uint[] memory arr) public returns (uint[] memory ) {
        if(arr.length < 2){
                //handle the edge case, for example return the original array.
                return arr;
        }

        uint[] memory temp = arr;

        uint i = 0;
        uint j= 0;
        uint key= 0;
        uint len = temp.length;

        for (i =1; i < len; i+=1) 
        {
            key = temp[i];
            j = i-1;
            while ((j> 0) && (temp[j] > key))
            {
                temp[j+1] = temp[j];
                j-=1;
            }
            temp[j+1] = key;
            
        }

        return temp;
    }
}