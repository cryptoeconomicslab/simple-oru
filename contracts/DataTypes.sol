pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

library DataTypes {
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
        bool v;
        bytes32 postStateRoot;
    }
}
