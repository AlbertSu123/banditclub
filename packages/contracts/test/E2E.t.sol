pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ancillary/SampleBanditClubContract.sol";
import "../src/BanditClub.sol";

contract E2E is Test {
    BanditClub c;
    address private bandit = mkaddr("bandit"); // bandit club member
    address private contractDeployer = mkaddr("contractDeployer"); // contract deployer who registers a contract to bandit club

    function testE2E() public {
        // Register a contract to Bandit Club
        vm.startPrank(contractDeployer);
        SampleBanditClubContract sample = new SampleBanditClubContract(
            address(c),
            contractDeployer
        );
        vm.stopPrank();

        // Subscribe to Bandit Club to use their contracts
        vm.startPrank(bandit);
        c.subscribe{value: 1 ether}(bandit);
        sample.doSomething();
        vm.stopPrank();

        // Collect fees as someone who has deployed contracts to bandit club
        vm.startPrank(contractDeployer);
        c.claimSubscriptionFees(address(sample));
        vm.stopPrank();
    }

    // ---------------- Utility Functions -------------------------
    function setUp() public {
        c = new BanditClub();
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        vm.deal(addr, 10 ether);
        return addr;
    }
}
