// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

contract BanditClub {
    // ------------------ External Functions ------------------------
    // Subscribe and start paying fees to Bandit Club
    function subscribe(address subscriber, uint256 feesPaid) external;

    function addContract(address ontract) external;

    // As a deployer of a Bandit Club contract, you can claim fees
    function claimSubscriptionFees() external;

    // When calling a function, check to make sure a user is subscribed
    // and they have enough points left
    function checkUser(address user) external;

    // ----------------- Internal Function -------------------------
    // For each contract, see how much fees are owed
    function calculateFeesOwed() internal;

    // Use this function to set the Usage Curve as desired
    function feesToPoints() internal;

    // Calculate how much points each action is worth
    function actionToPoints() internal;
}
