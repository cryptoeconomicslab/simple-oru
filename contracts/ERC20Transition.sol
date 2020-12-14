pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./DataTypes.sol";
import './lib/Math.sol';
import './ORUContext.sol';

/**
 * @title ERC20Transition
 */
contract ERC20Transition {
    struct ERC20Balance {
        address owner;
        address token;
        uint256 balance;
    }

    function transfer(
        bytes[] memory prevState,
        bytes memory params,
        bytes32[] memory postState
    ) public view {
        ORUContext context = ORUContext(msg.sender);
        ERC20Balance memory state1 = abi.decode(prevState[0], (ERC20Balance));
        ERC20Balance memory state2 = abi.decode(prevState[1], (ERC20Balance));
        (uint256 amount) = abi.decode(params, (uint256));
        require(context.getSender() == state1.owner);
        state1.balance -= amount;
        state2.balance += amount;
        require(keccak256(abi.encode(state1)) == postState[0]);
        require(keccak256(abi.encode(state2)) == postState[1]);
    }
}
