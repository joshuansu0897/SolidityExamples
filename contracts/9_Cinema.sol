// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Cinema is ERC20, Ownable {
    // initial statement
    uint256 price = 100; // price per token on wei

    // smart contract constructor
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) ERC20(_name, _symbol) {
        _mint(address(this), _totalSupply);
    }

    // Data structure to store customer information
    struct Customer {
        uint256 tokens_purchased;
        string[] movies_watched;
    }

    // Map to store customer information
    mapping(address => Customer) public Customers;

    // tokens management

    // function to set price of token
    function setPrice(uint256 _price) public {
        price = _price;
    }

    // function to get price of token
    function getPrice() public view returns (uint256) {
        return price;
    }

    // function to get price by tokens
    function getPriceByTokens(uint256 _tokens) public view returns (uint256) {
        return _tokens * price;
    }

    // get tokens by user, the result should be equal to getTokensByUser
    function getTokensByUser(address _user) public view returns (uint256) {
        return balanceOf(_user);
    }

    // get tokens by Customer, the result should be equal to getTokensByUser
    function getTokensByCustomer(address _user) public view returns (uint256) {
        return Customers[_user].tokens_purchased;
    }

    // function to min more tokens
    function mint(uint256 _amount) public onlyOwner {
        _mint(address(this), _amount);
    }

    // function to purchase tokens
    function purchaseTokens(uint256 _amount) public payable {
        uint256 _cost = _amount * price;

        require(msg.value >= _cost, "Insufficient funds for purchase");

        // obtain the number of tokens available on the smart contract
        uint256 _balance = balanceOf(address(this));

        require(_balance >= _amount, "Insufficient tokens in the contract");

        // return excess wai to the sender
        uint256 _cashToReturn = msg.value - _cost;
        payable(msg.sender).transfer(_cashToReturn);

        // transfer tokens to the sender
        _transfer(address(this), msg.sender, _amount);

        // save transaction information
        Customers[msg.sender].tokens_purchased += _amount;
    }

    // function to exchange tokens to ether
    function tokensToEther(uint256 _tokens) public payable {
        // validate customer tokens
        require(balanceOf(msg.sender) >= _tokens, "Insufficient tokens");

        // send tokens to smart contract
        _transfer(msg.sender, address(this), _tokens);

        // send ether to customer
        payable(msg.sender).transfer(getPriceByTokens(_tokens));
    }

    // company management

    // events
    event movie_watched(string, uint256, address);
    event movie_new(string, uint256);
    event movie_deleted(string);

    // data structure to store movie information
    struct Movie {
        string name;
        uint256 price;
        bool status;
    }

    // Map to store movie information
    mapping(string => Movie) public Movies;

    // array to store movie names
    string[] MovieNames;

    // incorporate movie into the Cinema
    function addMovie(string memory _name, uint256 _price) public onlyOwner {
        // validate movie name
        require(!Movies[_name].status, "Movie already exists");

        // save movie information
        Movies[_name] = Movie(_name, _price, true);

        // save movie name
        MovieNames.push(_name);

        // emit event
        emit movie_new(_name, _price);
    }

    // remove movie from the Cinema
    function removeMovie(string memory _name) public onlyOwner {
        // remove movie information
        Movies[_name].status = false;

        // emit event
        emit movie_deleted(_name);
    }

    // customer management

    // function to watch movie and pay with tokens ERC20
    function watchMovie(string memory _name) public {
        // validate movie name
        require(Movies[_name].status, "Movie does not exist");

        // validate customer tokens
        require(
            balanceOf(msg.sender) >= Movies[_name].price,
            "Insufficient tokens"
        );

        // send tokens to smart contract
        _transfer(msg.sender, address(this), Movies[_name].price);

        // save transaction information
        Customers[msg.sender].movies_watched.push(_name);

        // emit event
        emit movie_watched(_name, Movies[_name].price, msg.sender);
    }

    // information storage

    // function to visualize the movie history
    function getMovieHistory(address _user)
        public
        view
        returns (string[] memory)
    {
        return Customers[_user].movies_watched;
    }

    // function to visualize avilable movies
    function getAvailableMovies() public view returns (string[] memory) {
        return MovieNames;
    }

    // Extraction of wei from the smart contract
    function withdraw() external payable onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }
}
