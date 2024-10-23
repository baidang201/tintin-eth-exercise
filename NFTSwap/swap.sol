// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract GameItem is ERC721URIStorage {
    uint256 private _nextTokenId;

    constructor() ERC721("GameItem", "ITM") {}

    function awardItem(address player, string memory tokenURI) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _mint(player, tokenId);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }
}

contract Swap {
    uint256 _nextOrderId;

    struct Order {
        uint256 tokenId;
        uint256 price;
        address owner;

    }

    mapping(uint256 => Order) public OrderList;
    mapping(uint256 => uint256) public NftIdtoOrderId;

    function list(address _nftContract, uint256 _tokenId, uint256 _price) public  {

        IERC721 nftContract = IERC721(_nftContract);

        // Approve the marketplace to transfer the NFT
        require(nftContract.isApprovedForAll(msg.sender, address(this)) || nftContract.getApproved(_tokenId) == address(this), "Marketplace not approved");

        //approve(address(this), _tokenId);
        NftIdtoOrderId[_tokenId] = _nextOrderId;
        OrderList[_nextOrderId++] = Order ({
            tokenId: _tokenId,
            price: _price,
            owner: msg.sender
        });
    }

    function revoke(uint256 _orderId) public  {
        Order memory o = OrderList[_orderId];

        delete NftIdtoOrderId[o.tokenId];
        delete OrderList[_orderId];
    }

    function update(uint256 _orderId, uint256 _price ) public {
        Order memory o = OrderList[_orderId];
        o.price = _price;
        OrderList[_orderId] = o;
    }

    function purchase(address _nftContract, uint256 _orderId) public payable {

        IERC721 nftContract = IERC721(_nftContract);

        Order memory o = OrderList[_orderId];

        nftContract.transferFrom(o.owner, msg.sender, o.tokenId);

        // 将标价金额转移给卖家
        payable(o.owner).send(msg.value);
        // 将支付的多余金额返回给买家
        payable(msg.sender).send(msg.value - o.price);

        delete NftIdtoOrderId[o.tokenId];
        delete OrderList[_orderId];

    }
}