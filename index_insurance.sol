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
  address public farmer;
  address public oracle;
  address public creator;

  // Initializing the contract and setting the variables
  constructor(uint _premium, uint _payout, uint _indexThreshold, address _oracleAddress) {
    premium = _premium;
    payout = _payout;
    indexThreshold = _indexThreshold;
    oracle = _oracleAddress;
    creator = msg.sender;
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
    //require(block.timestamp);

  }

  // Setting Premium in case of risk increase/decrease
  function setPremium(uint newPremium) public {
    premium = newPremium;
  }

  // Claim
  function claim(uint amount) public {
    require(msg.sender == farmer, "Only the farmer can claim the insurance.");

    // Checking if a drought has occurred
    bool isDrought = checkDrought();

    // Paying out the insurance if a drought has occurred
    if (isDrought) {
      payable(msg.sender).transfer(payout);
    }
  }
}
