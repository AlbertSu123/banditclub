// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

interface IBanditClub {
    // ------------------ External Functions ------------------------
    // Subscribe and start paying fees to Bandit Club
    function subscribe(address subscriber, uint256 feesPaid) external;

    // Add a contract to the registry
    function addContract(address cntrct, address owner) external;

    // As a deployer of a Bandit Club contract, you can claim fees
    function claimSubscriptionFees() external;
}
