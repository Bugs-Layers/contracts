// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract CarbonCredit is ERC20, Ownable, ERC20Permit {
    address public treeAddr;
    constructor(address initialOwner)
        ERC20("CarbonCredit", "CC")
        Ownable(initialOwner)
        ERC20Permit("CarbonCredit")
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function setTreeAddr(address addr) public onlyOwner {
        treeAddr = addr;
    }

    function grantCredit(address to, uint256 amount) public {
        require(msg.sender==treeAddr, "Only permitted to NFT Smart Contract");
        _mint(to, amount);
    }
}