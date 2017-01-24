pragma solidity ^0.4.2;

// testnet: 0xc62ea9d2311f4855afdb04b967f81d3382cfee10

contract Test {
    function check(bytes32 data, uint8 v, bytes32 r, bytes32 s) constant returns(address) {
      return ecrecover(data, v, r, s);
    }
}
