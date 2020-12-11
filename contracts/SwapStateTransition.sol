pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./DataTypes.sol";
import "./StateTransitionVerifier.sol";

/**
 * @title SwapStateTransition
 */
contract SwapStateTransition is StateTransitionVerifier {
    struct ERC20Balance {
        address owner;
        address token;
        uint256 balance;
    }
    struct SwapState {
        address token0;
        address token1;
        uint256 reserve0;
        uint256 reserve1;
    }

    function verifyStateTransition(
        bytes[] memory prevState,
        bytes32 method,
        bytes memory params,
        bytes32[] memory postState
    ) public override pure returns(bool) {
        if(method == keccak256("addLiquidity")) {
            return addLiquidity(prevState, params, postState);
        }else if(method == keccak256("removeLiquidity")) {
            return removeLiquidity(prevState, params, postState);
        }else if(method == keccak256("swap")) {
            return swap(prevState, params, postState);
        }
        return false;
    }

    function addLiquidity(
        bytes[] memory prevState,
        bytes memory params,
        bytes32[] memory postState
    ) public pure returns(bool) {
        SwapState memory swapState = abi.decode(prevState[0], (SwapState));
        ERC20Balance memory pair1 = abi.decode(prevState[1], (ERC20Balance));
        ERC20Balance memory pair2 = abi.decode(prevState[2], (ERC20Balance));
        ERC20Balance memory pairToken = abi.decode(prevState[3], (ERC20Balance));
        (uint256 amount0, uint256 amount1) = abi.decode(params, (uint256, uint256));
        pair1.balance -= amount0;
        pair2.balance -= amount1;
        swapState.reserve0 += amount0;
        swapState.reserve1 += amount1;
        pairToken.balance += amount0*amount1;
        require(keccak256(abi.encode(swapState)) == postState[0]);
        require(keccak256(abi.encode(pair1)) == postState[1]);
        require(keccak256(abi.encode(pair2)) == postState[2]);
        require(keccak256(abi.encode(pairToken)) == postState[3]);
        return true;
    }

    function removeLiquidity(
        bytes[] memory prevState,
        bytes memory params,
        bytes32[] memory postState
    ) public pure returns(bool) {
        return true;
    }

    function swap(
        bytes[] memory prevState,
        bytes memory params,
        bytes32[] memory postState
    ) public pure returns(bool) {
        return true;
    }

}
