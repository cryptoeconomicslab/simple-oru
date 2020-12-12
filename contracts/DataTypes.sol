pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

library DataTypes {
    struct BlockHeader {
        uint256 totalTransactions;
        uint64 blockNumber;
    }

    struct InclusionProof {
        Transaction transaction;
        uint256 index;
        bytes[] proof;
    }

    struct Transaction {
        bytes4 method;
        address to;
        address[] inputs;
        bytes data;
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes32 postStateRoot;
    }

    struct TransactionBody {
        bytes4 method;
        address to;
        address[] inputs;
        bytes data;
    }

}
