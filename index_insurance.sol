// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing the Oracle contract
// import "./IndexOracle.sol"; // maybe interaction with contract instance is better ??

// Creating the DroughtInsurance contract
contract DroughtInsurance {

  // Defining the variables
  uint public premium; // Premium amount in wei (1 ether = 10^18 wei)
  uint public payout; // Payout amount in wei
  int public indexThreshold; // The threshold index value for drought
  int public index;
  address public oracle; // create simple oracle with settable index data for different regions
  address public creator; // The address of the contract creator
  Farmer public newFarmer; // A new Farmer struct instance

  // Farmer struct to store farmer's information
  struct Farmer {
    string firstName;
    string lastName;
    uint region; // The region code of the farmer
    address farmerAccount;
    }

  // Mapping: map Farmer to available, claimable amount (aka obligation)
  mapping (address => uint) public farmerToObligation;
  // Mapping for future obligations
  mapping (address => uint) public farmerToFutureObligation;

  // Initializing the contract and setting the variables
  constructor(uint _premium, uint _payout, int _indexThreshold, address _oracleAddress) {
    premium = _premium;
    payout = _payout;
    indexThreshold = _indexThreshold;
    oracle = _oracleAddress;
    creator = msg.sender;
  }

    // Setting Premium in case of risk increase/decrease (only SC owner should be able to do it)
  function setPremium(uint newPremium) public {
    require(msg.sender == creator, "Only smart contract owner can set premium.");
    premium = newPremium;
  }

  // Setting Payout in case of risk increase/decrease (only SC owner should be able to do it)
  function setPayout(uint newPayout) public {
    require(msg.sender == creator, "Only smart contract owner can set payout.");
    payout = newPayout;
  }
  // farmer registration, adds farmer structure to mapping with claimable amount (aka obligation)
  function register(string memory _firstName, string memory _lastName, uint _region) public {
    newFarmer = Farmer(_firstName, _lastName, _region, msg.sender);
    farmerToObligation[msg.sender] = 0;
  }

  // Creating the function to buy the insurance
  // There should be a time constraint: only purchasable the year before
  function buyInsurance() public payable {
    require(msg.value == premium, "Incorrect premium amount.");
    farmerToObligation[msg.sender] = payout; // payout == claimable amount (aka obligation)
  }

  // Creating the function to check if a drought has occurred
  // This function is absolute shit. Please work on this.
  function checkDrought(uint region) public returns(bool) {
    if (region == 1) {
        index = -1;
    } else {
        index = 1;
    }
    if (index < indexThreshold) {
      return true;
    } else {
      return false;
    }
  }

  // Claim
  // I believe the claimer should pay the oracle fees, in order to avoid excessive claiming and subsequent
  function claim(uint amount, uint region) public {
    require(farmerToObligation[msg.sender] >= amount, "Your claimable amount is too low.");
    // Checking if a drought has occurred
    bool isDrought = checkDrought(region);

    // Paying out the insurance if a drought has occurred
    if (isDrought) {
      payable(msg.sender).transfer(amount); // send claimed amount
      farmerToObligation[msg.sender] -= amount; // reduce obligation by amount claimed
    }
  }
}
