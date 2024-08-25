// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@5.0.2/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICarbonCredit is IERC20 {
    function grantCredit(address, uint256) external;
}

contract NFTree is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;

    ICarbonCredit public cc;

    struct dailyCheckState {
        uint256 approvals;
        uint256 lastClaimTime;
        uint256 lastVerificationTime;
    }

    mapping(uint256 => dailyCheckState) private statemap;

    constructor(address initialOwner, address _cc)
        ERC721("NFTree", "TRE")
        Ownable(initialOwner)
    {
        cc = ICarbonCredit(_cc);
    }

    function safeMint(address to, string memory uri) public {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        statemap[tokenId] = dailyCheckState({
            approvals: 0,
            lastClaimTime: block.timestamp,
            lastVerificationTime: block.timestamp
        });
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Additional functionality added by us

    function getTreeApprovals(uint256 tokenId) public view returns (uint256) {
        _requireOwned(tokenId);
        return statemap[tokenId].approvals;
    }

    function getTreeClaimDate(uint256 tokenId) public view returns (uint256) {
        _requireOwned(tokenId);
        return statemap[tokenId].lastClaimTime;
    }

    function getTreeLastVerified(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        _requireOwned(tokenId);
        return statemap[tokenId].lastVerificationTime;
    }

    function claimCredit(address to, uint256 tokenId) public {
        require(_requireOwned(tokenId) == msg.sender, "You don't own the Tree");
        require(
            block.timestamp - statemap[tokenId].lastClaimTime > 1 days,
            "Can't claim more than once a day"
        );
        require(
            block.timestamp - statemap[tokenId].lastVerificationTime < 1 days,
            "No tree updates in a day"
        );
        require(statemap[tokenId].approvals > 4, "Approval not reached 5");
        uint256 ndays = ((block.timestamp - statemap[tokenId].lastClaimTime) /
            1 days);
        cc.grantCredit(to, ndays);
        statemap[tokenId].lastClaimTime = block.timestamp;
    }

    function verifyDaily(uint256 tokenId) public {
        require(_requireOwned(tokenId) == msg.sender, "You don't own the Tree");
        statemap[tokenId].lastVerificationTime = block.timestamp;
        statemap[tokenId].approvals = 0;
    }

    function approveDaily(uint256 tokenId) public {
        _requireOwned(tokenId);
        require(balanceOf(msg.sender) > 0);
        statemap[tokenId].approvals++;
    }
}
