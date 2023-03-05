// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
import "forge-std/console.sol";
import "./dev/functions/FunctionsClient.sol";

contract BanditClub {
    // ------------------ Data Structures ---------------------------
    struct member {
        address feeRecipient;
        uint256 points;
    }
    mapping(address => member) public registeredContracts; // contract address => struct member
    mapping(address => uint256) public userPoints; // user address => points
    address[] public registeredContractsList;
    uint256 public registeredContractsCount;
    mapping(address => address[]) public userAdddressToContracts; // user address => list of their registered addresses
    mapping(address => uint256) public totalRegisteredContractsForUser; // user address

    uint256 public memberFees; // Amount of fees that belong to the members(contracts)
    uint256 public clubFees; // Amount of fees that belong to the club
    uint256 public totalPoints; // Total number of points in existence

    uint256 constant split = 9; // 90% of fees go to members, 10% goes to bandit club
    uint256 constant denom = 10;

    address FunctionOracleProxy = 0x649a2C205BE7A3d5e99206CEEFF30c794f0E31EC;

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
        registeredContractsList.push(cntrct);
        registeredContractsCount += 1;
        userAdddressToContracts[feeRecipient].push(cntrct);
        totalRegisteredContractsForUser[feeRecipient] += 1;
        // TODO: Call every function in the cntrct to make sure they are gated
    }

    function previewSubscriptionFeeClaim(address cntrct)
        public
        view
        returns (uint256)
    {
        member storage m = registeredContracts[cntrct];
        uint256 feesOwed = calculateFeesOwed(m.points);
        return feesOwed;
    }

    // As a deployer of a Bandit Club contract, you can claim fees
    function claimSubscriptionFees(address cntrct) public {
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
    function checkUserCall(address user, address cntrct) public {
        require()
        userPoints[user] -= actionToPoints();
        member storage m = registeredContracts[cntrct];
        m.points += actionToPoints();
        require(userPoints[user] >= 0, "Not enough points for this function");
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
    function actionToPoints() public pure returns (uint256) {
        // TODO: figure out how many points an action is worth
        return 100;
    }

  bytes public requestCBOR;
  bytes32 public latestRequestId;
  bytes public latestResponse;
  bytes public latestError;
  uint64 public subscriptionId;
  uint32 public fulfillGasLimit;
  uint256 public updateInterval;
  uint256 public lastUpkeepTimeStamp;
  uint256 public upkeepCounter;
  uint256 public responseCounter;
  string public API_ENDPOINT = "https://hub.snapshot.org/graphql";

  event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

  /**
   * @notice Executes once when a contract is created to initialize state variables
   * 
   * @param oracle The FunctionsOracle contract
   * @param _subscriptionId The Functions billing subscription ID used to pay for Functions requests
   * @param _fulfillGasLimit Maximum amount of gas used to call the client contract's `handleOracleFulfillment` function
   * @param _updateInterval Time interval at which Chainlink Automation should call performUpkeep
   */
  constructor(
    address oracle,
    uint64 _subscriptionId,
    uint32 _fulfillGasLimit,
    uint256 _updateInterval
  ) FunctionsClient(oracle) ConfirmedOwner(msg.sender) {
    updateInterval = _updateInterval;
    subscriptionId = _subscriptionId;
    fulfillGasLimit = _fulfillGasLimit;
    lastUpkeepTimeStamp = block.timestamp;
  }

  /**
   * @notice Generates a new Functions.Request. This pure function allows the request CBOR to be generated off-chain, saving gas.
   * 
   * @param source JavaScript source code
   * @param secrets Encrypted secrets payload
   * @param args List of arguments accessible from within the source code
   */
  function generateRequest (
    string calldata source,
    bytes calldata secrets,
    Functions.Location secretsLocation,
    string[] calldata args
  ) public pure returns (bytes memory) {
    Functions.Request memory req;
    req.initializeRequest(Functions.Location.Inline, Functions.CodeLanguage.JavaScript, source);
    if (secrets.length > 0) {
      if (secretsLocation == Functions.Location.Inline) {
        req.addInlineSecrets(secrets);
      } else {
        req.addRemoteSecrets(secrets);
      }
    }
    if (args.length > 0) req.addArgs(args);

    return req.encodeCBOR();
  }

  /**
   * @notice Sets the bytes representing the CBOR-encoded Functions.Request that is sent when performUpkeep is called

   * @param _subscriptionId The Functions billing subscription ID used to pay for Functions requests
   * @param _fulfillGasLimit Maximum amount of gas used to call the client contract's `handleOracleFulfillment` function
   * @param _updateInterval Time interval at which Chainlink Automation should call performUpkeep
   * @param newRequestCBOR Bytes representing the CBOR-encoded Functions.Request
   */
  function setRequest(
    uint64 _subscriptionId,
    uint32 _fulfillGasLimit,
    uint256 _updateInterval,
    bytes calldata newRequestCBOR
  ) external onlyOwner {
    updateInterval = _updateInterval;
    subscriptionId = _subscriptionId;
    fulfillGasLimit = _fulfillGasLimit;
    requestCBOR = newRequestCBOR;
  }

  /**
   * @notice Used by Automation to check if performUpkeep should be called.
   * 
   * The function's argument is unused in this example, but there is an option to have Automation pass custom data
   * that can be used by the checkUpkeep function.
   * 
   * Returns a tuple where the first element is a boolean which determines if upkeep is needed and the
   * second element contains custom bytes data which is passed to performUpkeep when it is called by Automation.
   */
  function checkUpkeep(
    bytes memory
  ) public view override returns (bool upkeepNeeded, bytes memory) {
    upkeepNeeded = (block.timestamp - lastUpkeepTimeStamp) > updateInterval;
  }

  /**
   * @notice Called by Automation to trigger a Functions request
   * 
   * The function's argument is unused in this example, but there is an option to have Automation pass custom data
   * returned by checkUpkeep (See Chainlink Automation documentation)
   */
  function performUpkeep(
    bytes calldata
  ) external override {
    (bool upkeepNeeded, ) = checkUpkeep("");
    require(upkeepNeeded, "Time interval not met");
    lastUpkeepTimeStamp = block.timestamp;
    upkeepCounter = upkeepCounter + 1;

    bytes32 requestId = s_oracle.sendRequest(
      subscriptionId,
      requestCBOR,
      fulfillGasLimit
    );

    s_pendingRequests[requestId] = s_oracle.getRegistry();
    emit RequestSent(requestId);
    latestRequestId = requestId;
  }

  /**
   * @notice Callback that is invoked once the DON has resolved the request or hit an error
   *
   * @param requestId The request ID, returned by sendRequest()
   * @param response Aggregated response from the user code
   * @param err Aggregated error from the user code or from the execution pipeline
   * Either response or error parameter will be set, but never both
   */
  function fulfillRequest(
    bytes32 requestId,
    bytes memory response,
    bytes memory err
  ) internal override {
    latestResponse = response;
    latestError = err;
    responseCounter = responseCounter + 1;
    emit OCRResponse(requestId, response, err);
  }

  /**
   * @notice Allows the Functions oracle address to be updated
   *
   * @param oracle New oracle address
   */
  function updateOracleAddress(address oracle) public onlyOwner {
    setOracle(oracle);
  }
}
}
