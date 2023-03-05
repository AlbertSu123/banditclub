# Overview
Bandit Club is a new paradigm in smart contract monetization. Individuals pay a subscription fee to Bandit Club based on their addresses total volume. Bandit Club keeps 10% of the subscription fee. The remainder is distributed to the deployers of the smart contracts that the individual user has interacted with. It will initially be divided and based on # of interactions with each contract, but the DAO can change the pricing structure as necessary.

Smart contracts can opt to only take users if they are Bandit Club subscribers, thus ensuring they are getting paid on every interaction. This will create a powerful feedback loop where more people will subscribe to gain access, which will in turn have more developers add the restriction on their contract, which will encourage more people to subscribe, etc. There is near zero fork risk for n+2 protocol after n, n+1 protocol on board as they inherit their network effects.

Smart contracts can currently only monetize with fees (introducing fork risk) or tokens (introduce regulation risk, and lacking USD-denominated cashflows). Bandit Club introduces a third option.

## Integration
See the sample contract at `SampleBanditClubContract.sol`

1. Import the `IBanditClub.sol` interface
```
import "../IBanditClub.sol";
```
2. Add the bandit club state variable to your contract
```
IBanditClub banditClub;

constructor(address BanditClub) {
    banditClub = IBanditClub(BanditClub);
}
```
3. Create the `checkUser` modifier
```
modifier checkUser(address user) {
    banditClub.checkUserCall(user);
    _;
}
```
4. Add `checkUser` modifier to every function
```
function doSomething() public checkUser(msg.sender) {}
```
