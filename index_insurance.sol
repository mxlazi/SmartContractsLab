// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing the Oracle contract
import "./IndexOracle.sol"; // maybe interaction with contract instance is better ??

// Creating the DroughtInsurance contract
contract DroughtInsurance {

  // Defining the variables
  uint public premium; // in wei ??
  uint public payout; // in wei ?? // change variable name to more comprehensible one
  uint public indexThreshold;
  address public oracle; // create simple oracle with settable index data for different regions
  address public creator;

  struct Farmer {
    string firstName;
    string lastName;
    uint region;
    address farmerAccount;
    }

  // Mapping to map Farmer to available, claimable amount (aka obligation)
  mapping (Farmer => uint) public farmerToObligation;

  // Initializing the contract and setting the variables
  constructor(uint _premium, uint _payout, uint _indexThreshold, address _oracleAddress) {
    premium = _premium;
    payout = _payout;
    indexThreshold = _indexThreshold;
    oracle = _oracleAddress;
    creator = msg.sender;
  }

  // farmer registration, adds farmer structure to mapping with claimable amount (aka obligation)
  function _register(string _firstName, string _lastName, uint _region) internal {
    farmerToObligation[Farmer(_firstName, _lastName, _region, msg.sender)] = 0;
  }

  // Creating the function to check if a drought has occurred
  // This function is absolute shit. Please work on this.
  function checkDrought() public view returns(bool) {
    uint index = oracle.getIndex();
    if (index < indexThreshold) {
      return true;
    } else {
      return false;
    }
  }

  // Creating the function to buy the insurance
  // There should be a time constraint: only purchasble the year before
  function buyInsurance() public payable {
    require(msg.value == premium, "Incorrect premium amount.");
    farmerToObligation[msg.sender] = payout; // payout == claimable amount (aka obligation)
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

  // Claim
  function claim(uint amount) public {
    require(obligationToFarmer[msg.sender] >= amount, "Your claimable amount is too low.");
    // Checking if a drought has occurred
    bool isDrought = checkDrought();

    // Paying out the insurance if a drought has occurred
    if (isDrought) {
      payable(msg.sender).transfer(amount); // send claimed amount
      obligationToFarmer[msg.sender] -= amount; // reduce obligation by amount claimed
    }
  }
}
