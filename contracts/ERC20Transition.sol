pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./DataTypes.sol";
import "./StateTransitionVerifier.sol";
import './lib/Math.sol';

/**
 * @title ERC20Transition
 */
contract ERC20Transition is StateTransitionVerifier {
    struct ERC20Balance {
        address owner;
        address token;
        uint256 balance;
    }

    function verifyStateTransition(
        bytes[] memory prevState,
        address sender,
        bytes32 method,
        bytes memory params,
        bytes32[] memory postState
    ) public override pure returns(bool) {
        if(method == keccak256("transfer")) {
            return transfer(prevState, sender, params, postState);
        }
        return false;
    }

    function transfer(
        bytes[] memory prevState,
        address sender,
        bytes memory params,
        bytes32[] memory postState
    ) public pure returns(bool) {
        ERC20Balance memory state1 = abi.decode(prevState[0], (ERC20Balance));
        ERC20Balance memory state2 = abi.decode(prevState[1], (ERC20Balance));
        (uint256 amount) = abi.decode(params, (uint256));
        require(sender == state1.owner);
        state1.balance -= amount;
        state2.balance += amount;
        require(keccak256(abi.encode(state1)) == postState[0]);
        require(keccak256(abi.encode(state2)) == postState[1]);
        return true;
    }
}
