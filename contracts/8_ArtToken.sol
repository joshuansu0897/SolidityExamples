// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtToken is ERC721, Ownable {
    // initial statement

    // smart contract constructor
    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    // NFT token counter
    uint256 COUNTER;

    // Token price in wei (1 eth = 1e18 wei) (price of the artwork)
    uint256 fee = 5 wei;

    // Data structure with the properties of the artwork
    struct Art {
        string name;
        uint256 id;
        uint256 dna;
        uint8 level;
        uint8 rarity;
    }

    // storage data structure, this is to keep artwork
    Art[] public art_works;

    // declaration of the events
    event NewArtWork(
        address indexed owner,
        string name,
        uint256 id,
        uint256 dna
    );

    // Declaration of the functions

    // Create a random number
    function _random(uint256 _mod) internal view returns (uint256) {
        uint256 random_number = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender))
        );
        return random_number % _mod;
    }

    // NFT token creation
    function _createArtWork(string memory _name) internal {
        uint8 rand_rarity = uint8(_random(1000));
        uint256 rand_dna = uint256(_random(10**16));

        Art memory new_art = Art(_name, COUNTER, rand_dna, 1, rand_rarity);

        art_works.push(new_art);

        _safeMint(msg.sender, COUNTER);

        emit NewArtWork(msg.sender, _name, COUNTER, rand_dna);

        COUNTER++;
    }

    // NFT token price update
    function updatePrice(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    // Visualize the balance of the smart contract (wei)
    function infoSmartContract() public view returns (address, uint256) {
        address smart_contract_address = address(this);
        uint256 smart_contract_balance = address(this).balance;
        return (smart_contract_address, smart_contract_balance);
    }

    // obtain all created artwork
    function getAllArtWorks() public view returns (Art[] memory) {
        return art_works;
    }

    // obtain the artwork by user
    function getArtWorksByUser(address _owner) public view returns (Art[] memory) {
        Art[] memory user_artworks = new Art[](balanceOf(_owner));
        
        uint256 counter_art = 0;
        for (uint256 i = 0; i < art_works.length; i++) {
            if (ownerOf(i) == _owner) {
                user_artworks[counter_art] = art_works[i];
                counter_art++;
            }
        }

        return user_artworks;
    }

    // NFT token development

    // NFT Token payment
    function createRandomArtWork(string memory _name) public payable {
        require(msg.value >= fee);
        _createArtWork(_name);
    }

    // Extraction of wei from the smart contract
    function withdraw() external payable onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    // Level up the artwork
    function levelUp(uint256 _id) public {
        require(ownerOf(_id) == msg.sender);
        Art storage art = art_works[_id];
        art.level++;
        art_works[_id] = art;
    }
}
