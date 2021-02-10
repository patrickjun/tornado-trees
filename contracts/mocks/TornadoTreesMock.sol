// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../TornadoTrees.sol";
import "../interfaces/ITornadoTreesV1.sol";
import "../interfaces/IBatchTreeUpdateVerifier.sol";

contract TornadoTreesMock is TornadoTrees {
  uint256 public currentBlock;

  constructor(
    address _governance,
    address _tornadoProxy,
    ITornadoTreesV1 _tornadoTreesV1,
    IBatchTreeUpdateVerifier _treeUpdateVerifier,
    SearchParams memory _searchParams
  ) public TornadoTrees(_governance, _tornadoProxy, _tornadoTreesV1, _treeUpdateVerifier, _searchParams) {}

  function setBlockNumber(uint256 _blockNumber) public {
    currentBlock = _blockNumber;
  }

  function blockNumber() public view override returns (uint256) {
    return currentBlock == 0 ? block.number : currentBlock;
  }

  function register(
    address _instance,
    bytes32 _commitment,
    bytes32 _nullifier,
    uint256 _depositBlockNumber,
    uint256 _withdrawBlockNumber
  ) public {
    setBlockNumber(_depositBlockNumber);
    registerDeposit(_instance, _commitment);

    setBlockNumber(_withdrawBlockNumber);
    registerWithdrawal(_instance, _nullifier);
  }

  function updateDepositTreeMock(
    bytes32 _oldRoot,
    bytes32 _newRoot,
    uint32 _pathIndices,
    TreeLeaf[] calldata _events
  ) public pure returns (uint256) {
    bytes memory data = new bytes(BYTES_SIZE);
    assembly {
      mstore(add(data, 0x44), _pathIndices)
      mstore(add(data, 0x40), _newRoot)
      mstore(add(data, 0x20), _oldRoot)
    }
    for (uint256 i = 0; i < CHUNK_SIZE; i++) {
      (bytes32 hash, address instance, uint32 depositBlock) = (_events[i].hash, _events[i].instance, _events[i].block);
      assembly {
        mstore(add(add(data, mul(ITEM_SIZE, i)), 0x7c), depositBlock)
        mstore(add(add(data, mul(ITEM_SIZE, i)), 0x78), instance)
        mstore(add(add(data, mul(ITEM_SIZE, i)), 0x64), hash)
      }
    }
    return uint256(sha256(data)) % SNARK_FIELD;
  }

  function updateDepositTreeMock2(
    bytes32 _oldRoot,
    bytes32 _newRoot,
    uint32 _pathIndices,
    TreeLeaf[] calldata _events
  ) public pure returns (bytes memory) {
    bytes memory data = new bytes(BYTES_SIZE);
    assembly {
      mstore(add(data, 0x44), _pathIndices)
      mstore(add(data, 0x40), _newRoot)
      mstore(add(data, 0x20), _oldRoot)
    }
    for (uint256 i = 0; i < CHUNK_SIZE; i++) {
      (bytes32 hash, address instance, uint32 depositBlock) = (_events[i].hash, _events[i].instance, _events[i].block);
      assembly {
        mstore(add(add(data, mul(ITEM_SIZE, i)), 0x7c), depositBlock)
        mstore(add(add(data, mul(ITEM_SIZE, i)), 0x78), instance)
        mstore(add(add(data, mul(ITEM_SIZE, i)), 0x64), hash)
      }
    }
    return data;
  }
}
