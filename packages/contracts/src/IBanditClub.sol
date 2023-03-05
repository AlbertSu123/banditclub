// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

interface IBanditClub {
    // ------------------ External Functions ------------------------
    // Subscribe and start paying fees to Bandit Club
    function subscribe(address subscriber, uint256 feesPaid) external;

    // Add a contract to the registry
    function registerContract(address cntrct, address owner) external;

    // As a deployer of a Bandit Club contract, you can claim fees
    function claimSubscriptionFees(address cntrct) external;

    // When calling a function, check to make sure a user is subscribed
    // and they have enough points left
    function checkUserCall(address user, address cntrct) external;
}
