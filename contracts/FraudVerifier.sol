pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Rollup.sol";
import "./DataTypes.sol";
import "./StateManager.sol";
import "./StateTransitionVerifier.sol";

/**
 * @title FraudVerifier
 */
contract FraudVerifier {
    address public rollupAddress;
    StateManager public prevStateManager;
    StateManager public postStateManager;
    bool public isFinalized;
    uint64 public blockNumber;

    constructor(address _rollupAddress) public {
        rollupAddress = _rollupAddress;
        isFinalized = false;
        blockNumber = 0;
    }

    function start(
        bytes32 prevStateRoot,
        bytes32 postStateRoot
    ) public {
        prevStateManager = new StateManager(prevStateRoot);
        postStateManager = new StateManager(postStateRoot);
    }

    function finalize(
        uint64 targetBlockNumber,
        bytes[] memory prevState,
        DataTypes.InclusionProof memory previousTransaction,
        DataTypes.InclusionProof memory transaction
    ) public {
        require(previousTransaction.index + 1 == transaction.index, "");
        // check rollup tx
        // require(verifyLeaf(previousTransaction))
        // require(verifyLeaf(transaction))

        bytes32[] memory postState = new bytes32[](transaction.transaction.inputs.length);
        for(uint i = 0;i < transaction.transaction.inputs.length;i++) {
            bytes32 prevStateHash = prevStateManager.getValue(transaction.transaction.inputs[i]);
            require(prevStateHash == keccak256(prevState[i]));
            postState[i] = postStateManager.getValue(transaction.transaction.inputs[i]);
        }

        require(prevStateManager.root() == previousTransaction.transaction.postStateRoot);
        require(
            StateTransitionVerifier(transaction.transaction.to).verifyStateTransition(prevState, transaction.transaction.method, transaction.transaction.data, postState)
        );
        // todo: the case it can not be verify state transition so far
        require(postStateManager.root() != transaction.transaction.postStateRoot);
        isFinalized = true;
        blockNumber = targetBlockNumber;
    }
}
