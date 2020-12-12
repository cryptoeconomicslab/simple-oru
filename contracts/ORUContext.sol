pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./FraudVerifier.sol";
import "./lib/LinkedList.sol";
import "./DataTypes.sol";

/**
 * @title ORUContext
 */
contract ORUContext {
    address public verifierAddress;

    constructor(address _verifierAddress) public {
        verifierAddress = _verifierAddress;
    }

    function getSender() public view returns(address) {
        return FraudVerifier(verifierAddress).sender();
    }
}
