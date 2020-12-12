pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./FraudVerifier.sol";
import "./lib/LinkedList.sol";
import "./DataTypes.sol";

/**
 * @title Rollup
 */
contract Rollup {
    using LinkedListLib for LinkedListLib.LinkedList;

    address public aggregatorAddress;
    // Current block number of commitment chain
    uint256 public currentBlock = 0;
    // History of Merkle Root
	LinkedListLib.LinkedList blocks;

    // Event definitions
    event BlockSubmitted(uint64 blockNumber, bytes32 root);

    modifier isAggregator() {
        require(
            msg.sender == aggregatorAddress,
            "msg.sender should be registered aggregator address"
        );
        _;
    }

    constructor(address _firstAggregator) public {
        aggregatorAddress = _firstAggregator;
    }

    function submitRoot(
        uint64 blkNumber,
        bytes32 _root,
        bytes[] memory _txs
    ) public isAggregator {
        require(
            currentBlock + 1 == blkNumber,
            "blkNumber should be next block"
        );
        DataTypes.BlockHeader memory blockHeader = DataTypes.BlockHeader({
            root: _root,
            totalTransactions: _txs.length,
            txHash: keccak256(abi.encode(_txs))
        });
        blocks.push(
            blkNumber,
            true,
            keccak256(abi.encode(blockHeader))
        );
        currentBlock = blkNumber;
        emit BlockSubmitted(blkNumber, _root);
    }

    function proveInvalidMerkleRoot(
        uint64 blkNumber,
        DataTypes.BlockHeader memory _blockHeader,
        bytes[] memory _txs
    ) public {
        // require(verifyMerkleRoot(_txs) != _root, "valid merkle root");
        require(_blockHeader.txHash == keccak256(abi.encode(_txs)), "valid transactions");
        require(blocks.getData(blkNumber) == keccak256(abi.encode(_blockHeader)), "valid block header");
        disableInvalidBlock(blkNumber);
    }

    function proveInvalidStateTransition(
        address verifier
    ) public {
        require(FraudVerifier(verifier).isFinalized());
        disableInvalidBlock(FraudVerifier(verifier).blockNumber());
    }

    function disableInvalidBlock(uint64 blkNumber) internal {
        blocks.remove(blkNumber);
    }

    function verifyBlockHeader(
        DataTypes.BlockHeaderProof memory _blockHeaderProof
    ) public returns (bool) {
        return blocks.getData(_blockHeaderProof.blockNumber) == keccak256(abi.encode(DataTypes.BlockHeader({
            root: _blockHeaderProof.root,
            totalTransactions: _blockHeaderProof.totalTransactions,
            txHash: _blockHeaderProof.txHash
        })));
    }
}
