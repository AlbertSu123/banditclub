// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "../IBanditClub.sol";

contract SampleBanditClubContract {
    IBanditClub banditClub;

    constructor(address BanditClub) {
        banditClub = IBanditClub(BanditClub);
    }

    // You would need to add the checkUser modifier to every functon and inherit the BanditClub contract
    function doSomething() public checkUser(msg.sender) {}

    // Just syntactic sugar to use a modifier instead of an internal function
    modifier checkUser(address user) {
        banditClub.checkUserCall(user);
        _;
    }
}
