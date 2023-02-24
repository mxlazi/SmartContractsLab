// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing the Oracle contract
import "./IndexOracle.sol"; // maybe interaction with contract instance is better

// Creating the DroughtInsurance contract
contract DroughtInsurance {

  // Defining the variables
  uint public premium;
  uint public payout;
  uint public indexThreshold;
  address public oracle;
  address public creator;

  struct Farmer {
    string firstName;
    string lastName;
    uint region;
    address farmerAccount;
    }

  Farmer[] public farmers;
  mapping (uint => address) public obligationToFarmer;

  // Initializing the contract and setting the variables
  constructor(uint _premium, uint _payout, uint _indexThreshold, address _oracleAddress) {
    premium = _premium;
    payout = _payout;
    indexThreshold = _indexThreshold;
    oracle = _oracleAddress;
    creator = msg.sender;
  }

  // farmer registration
  function _register(string _firstName, string _lastName, uint _region) internal {
    farmers.push(Farmer(_firstName, _lastName, _region, msg.sender));
  }

  // Creating the function to check if a drought has occurred
  function checkDrought() public view returns(bool) {
    for (uint day = 0; day < minimumDays; i++) {
      }
    uint index = oracle.getIndex();
    if (index < indexThreshold) {
      return true;
    } else {
      return false;
    }
  }

  // Creating the function to buy the insurance (only purchasable the year before)
  function buyInsurance() public payable {
    require(msg.value == premium, "Incorrect premium amount.");
    obligationToFarmer[msg.sender] = msg.value;
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
    require(obligationToFarmer[msg.sender] >= amount, "Your obligation is too low.");
    // Checking if a drought has occurred
    bool isDrought = checkDrought();

    // Paying out the insurance if a drought has occurred
    if (isDrought) {
      payable(msg.sender).transfer(amount); // send claimed amount
      obligationToFarmer[msg.sender] -= amount; // reduce obligation by amount claimed
    }
  }
}
