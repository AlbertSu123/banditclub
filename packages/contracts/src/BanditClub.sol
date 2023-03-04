// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
import "forge-std/console.sol";

contract BanditClub {
    // ------------------ Data Structures ---------------------------
    struct member {
        address feeRecipient;
        uint256 points;
    }
    mapping(address => member) registeredContracts; // contract address => struct member
    mapping(address => uint256) userPoints; // user address => points

    uint256 memberFees; // Amount of fees that belong to the members(contracts)
    uint256 clubFees; // Amount of fees that belong to the club
    uint256 totalPoints; // Total number of points in existence

    uint256 constant split = 9; // 90% of fees go to members, 10% goes to bandit club
    uint256 constant denom = 10;

    // ------------------ External Functions ------------------------
    // Subscribe and start paying fees to Bandit Club
    function subscribe(address subscriber) external payable {
        uint256 points = feesToPoints(msg.value);
        userPoints[subscriber] += points;
        totalPoints += points;

        memberFees += (msg.value * split) / denom;
        clubFees += (msg.value * (denom - split)) / denom;
    }

    // Add a contract to the registry
    function registerContract(address cntrct, address feeRecipient) external {
        require(
            registeredContracts[cntrct].feeRecipient == address(0),
            "Contract already registered"
        );
        registeredContracts[cntrct] = member({
            feeRecipient: feeRecipient,
            points: 0
        });
    }

    // As a deployer of a Bandit Club contract, you can claim fees
    function claimSubscriptionFees(address cntrct) external {
        member storage m = registeredContracts[cntrct];
        uint256 feesOwed = calculateFeesOwed(m.points);
        totalPoints -= m.points;
        m.points = 0;

        (bool sent, bytes memory data) = m.feeRecipient.call{value: feesOwed}(
            ""
        );
        require(sent, "Failed to send Ether");
    }

    // When calling a function, check to make sure a user is subscribed
    // and they have enough points left
    function checkUserCall(address user) public {
        userPoints[user] -= actionToPoints();
        require(userPoints[user] >= 0);
    }

    // ----------------- Internal Functions -------------------------
    // For each contract, see how much fees are owed
    function calculateFeesOwed(uint256 points) internal view returns (uint256) {
        return (memberFees * points) / totalPoints;
    }

    // Use this function to set the Usage Curve as desired
    function feesToPoints(uint256 fees) internal pure returns (uint256) {
        // TODO: determine implementation details for usage curve
        return fees;
    }

    // Calculate how much points each action is worth
    function actionToPoints() internal pure returns (uint256) {
        // TODO: figure out how many points an action is worth
        return 1;
    }
}
