pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./FraudVerifier.sol";

/**
 * @title Rollup
 */
contract Rollup {
    address public aggregatorAddress;
    // Current block number of commitment chain
    uint256 public currentBlock = 0;
    // History of Merkle Root
    mapping(uint256 => bytes32) public blocks;

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
        blocks[blkNumber] = keccak256(abi.encode(_root, _txs));
        currentBlock = blkNumber;
        emit BlockSubmitted(blkNumber, _root);
    }

    function proveInvalidMerkleRoot(
        uint64 blkNumber,
        bytes32 _root,
        bytes[] memory _txs
    ) public {
        // require(verifyMerkleRoot(_txs) != _root, "valid merkle root");
        require(blocks[blkNumber] == keccak256(abi.encode(_root, _txs)));
        disableInvalidBlock(blkNumber);
    }

    function proveInvalidStateTransition(
        address verifier
    ) public {
        require(FraudVerifier(verifier).isFinalized());
        disableInvalidBlock(FraudVerifier(verifier).blockNumber());
    }

    function disableInvalidBlock(uint64 blkNumber) internal {
        delete blocks[blkNumber];
    }
}
