// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// we will need to call the contract we have deployed befpore to check for addresses that werer whitelisted before 
// and give those adress pressale access
// so we can creat interface for whitelist contract with a function only for this mapping
// wee just need to return mappin adress => boolean
// this way we dont need to inherit and deplot the entire whitlist contract but only part of it

interface IWhiteList {
    function whitelistedAddress(address) external view returns (bool) ; 
}