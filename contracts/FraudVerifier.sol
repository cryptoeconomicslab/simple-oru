pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Rollup.sol";
import "./DataTypes.sol";
import "./StateManager.sol";

/**
 * @title FraudVerifier
 */
contract FraudVerifier {
    address public rollupAddress;
    StateManager public prevStateManager;
    StateManager public postStateManager;
    bool public isFinalized;
    uint64 public blockNumber;
    address public sender;

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
        DataTypes.BlockHeaderProof memory prevHeader,
        DataTypes.BlockHeaderProof memory postHeader,
        DataTypes.InclusionProof memory previousTransaction,
        DataTypes.InclusionProof memory transaction
    ) public {
        // Rollup(rollupAddress).block
        if(prevHeader.blockNumber == postHeader.blockNumber) {
            require(previousTransaction.index + 1 == transaction.index, "");
        } else if(prevHeader.blockNumber + 1 == postHeader.blockNumber) {
            require(previousTransaction.index == prevHeader.totalTransactions - 1 && transaction.index == 0, "");
        } else {
            assert(false);
        }
        // check rollup tx
        require(Rollup(rollupAddress).verifyBlockHeader(prevHeader), "invalid prevHeader");
        require(Rollup(rollupAddress).verifyBlockHeader(postHeader), "invalid postHeader");
        // require(verifyLeaf(previousTransaction))
        // require(verifyLeaf(transaction))

        bytes32[] memory postState = new bytes32[](transaction.transaction.inputs.length);
        for(uint i = 0;i < transaction.transaction.inputs.length;i++) {
            bytes32 prevStateHash = prevStateManager.getValue(transaction.transaction.inputs[i]);
            require(prevStateHash == keccak256(prevState[i]));
            postState[i] = postStateManager.getValue(transaction.transaction.inputs[i]);
        }

        require(prevStateManager.root() == previousTransaction.transaction.postStateRoot);
        // recover sender from signature
        sender = ecrecover(keccak256(abi.encode(getTxBody(transaction.transaction))), transaction.transaction.v, transaction.transaction.r, transaction.transaction.s);
        // call function
        (bool success,  ) = transaction.transaction.to.call(abi.encodeWithSelector(
            transaction.transaction.method,
            prevState,
            transaction.transaction.data,
            postState
        ));
        if(success) {
            require(postStateManager.root() != transaction.transaction.postStateRoot);
        } else {
            require(previousTransaction.transaction.postStateRoot != transaction.transaction.postStateRoot);
        }
        isFinalized = true;
        blockNumber = targetBlockNumber;
    }

    function getTxBody(DataTypes.Transaction memory tx) private returns (DataTypes.TransactionBody memory) {
        return DataTypes.TransactionBody({
            method: tx.method,
            to: tx.to,
            inputs: tx.inputs,
            data: tx.data
        });
    }
}
