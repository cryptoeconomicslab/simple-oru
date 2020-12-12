pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


interface StateTransitionVerifier {
    function verifyStateTransition(
        bytes[] calldata prevState,
        address sender,
        bytes32 method,
        bytes calldata params,
        bytes32[] calldata postState
    ) external pure returns (bool);
}