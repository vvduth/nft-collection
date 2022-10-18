// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    // @dev _baseTokenURI for computing {tokenURI}. if set ,the resulting for each
    // token will be the concatenation of the based url and the tokenid 
    string _baseTokenURI ; 
    
    // _preice i sthe price of one nft
    uint256 public _price = 0.01 ether ;

    //_paused is used tp pasue the contract in case of an emergency
    bool public _paused ; 

    // max number of contracts
    uint256 public maxTokenIds = 20 ; 

    // total number of token ids minted : 
    uint256 public tokenIds ; 

    //White list contract instane
    IWhiteList whitelist ; 

     // boolean to define if the presale is start or not
    bool public preSaleStarted ; 

    // timestamp for pre sale would end
    uint256 public preSaleEnded; 

    modifier onlyWhenNotPaused {
        require(!_paused , "Contract currently paused cuz some bug happened!");
        _;
    }

    // erc721 constructore takes in a name and a symbol to the tokem colletion
    // it also takes in the base URL to set _basetokenURI for the collection
    // once again _basetokenURI = tokenId + base url
    constructor (string memory baseURI, address whitelistContract) {
        _baseTokenURI = baseURI ; 
        whitelist = IWhiteList(whitelistContract) ; 

    }

    // pre sale start a presale for the white listed address 
    function startPreSale() public onlyOwner {
        preSaleStarted = true ;
        // Set presaleEnded time as current timestamp + 5 minutes
        // Solidity has cool syntax for timestamps (seconds, minutes, hours, days, years)
        presaleEnded = block.timestamp + 5 minutes;
    }

    // presaleMinty allow a user to mint one NFT per transaction durtig the presale
    function preSaleMint()  public payable onlyWhenNotPaused {
        require(preSaleStarted && block.timestamp < presaleEnded, "Presale is not running bra"); 
        require(whitelist.whitelistedAddress(msg.sender), "you are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceed the community supply");
        require(msg.value >= price, "Please send enough ETH bra");
        tokenIds += 1 ; 
        //_safeMint is a safer version of the _mint function as it ensures that
        // if the address being minted to is a contract, then it knows how to deal with ERC721 tokens
        // If the address being minted to is not a contract, it works the same way as _mint
        _safeMint(msg.sender, tokenIds) ; 
    } 
       /**
    * @dev mint allows a user to mint 1 NFT per transaction after the presale has ended.
    */
    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    /**
    * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
    * returned an empty string for the baseURI
    */
   function _basedURI() interval view virtual override returns (string memory) {
    return _baseTokenURI ;
   }

   // set paused maske the contract paused or unpasued
   function setPaused(bool val) public onlyOwner {
    _paused = val ; 
   }

   // withdraw sends all the eth in the contract to the owner of the contract
   function withdraw() public onlyOwner {
    address _owner = owner() ;
    uint256 amount = address(this).balance ; 
    (bool sent, ) = _owner.call{value: amount}("") ; 
   }

     // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}