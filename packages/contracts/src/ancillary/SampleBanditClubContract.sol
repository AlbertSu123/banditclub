// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "../BanditClub.sol";

contract SampleBanditClubContract is BanditClub {
    // You would need to add the checkUser modifier to every functon and inherit the BanditClub contract
    function doSomething() public checkUser(msg.sender) {}
}
