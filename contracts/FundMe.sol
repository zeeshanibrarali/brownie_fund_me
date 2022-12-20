// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
import "C:/Users/Admin/demos/brownie_fund_me/contracts/tests/MockV3Aggregator.sol";

contract FundMe{

    mapping(address => uint256)public fundedamount;
    address public owner;
    AggregatorV3Interface public priceFeed;
    address[]public funders;
    constructor(address _priceFeed) public{
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund()public payable {
        uint256 minimum = 5;
        require(convert(msg.value) >= minimum,"You need to spend more ETH.....");
        fundedamount[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getPrice() public view returns (uint256){
        (,int256 answer,,,)= priceFeed.latestRoundData();
        return uint256(answer);

    }//119783000000 = 1,197.83000000

    function convert(uint256 amount)public view returns(uint256){
        uint256 ether1 = getPrice();
        return (ether1 * amount/100000000);
    }// 1210.61560000

    function getEntranceFee() public view returns (uint256){
        // minimumUSD
        uint minimumUSD = 50 * 10**18;
        uint price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision)/ price;
    }

    modifier OnlyOwner {
        require(msg.sender == owner);
        _;
    }
    function Withdraw()public OnlyOwner payable{       
        payable(msg.sender).transfer(address(this).balance);
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            fundedamount[funder] = 0;
        }
        funders = new address[](0);
    }
}
