pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Rollup.sol";
import "./DataTypes.sol";

/**
 * @title StateManager
 */
contract StateManager {
    bytes32 public root;
    mapping(address => bytes32) public states;

    constructor(bytes32 _root) public {
        root = _root;
    }

    function verifyState(
        address key,
        bytes32 value,
        bytes[] memory proof
    ) public {
        // require(verifyLeaf(root, key, value, proof));
        states[key] = value;
    }

    function getValue(
        address key
    ) public returns (bytes32) {
        return states[key];
    }

}
