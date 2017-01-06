pragma solidity ^0.4.4;

import "owned.sol";

contract tokenTracker is owned {
    
    uint public count;
    
    mapping(uint => address)   public addr; 
    mapping(address => uint)   public index;
    mapping(address => uint)   public decimals;
    mapping(address => string) public symbol;
    mapping(address => string) public name;
    mapping(address => mapping(bytes32 => string))   public extra;

    function link(address _addr) internal {
        var i = index[_addr];
        if(i == 0) {
            i = ++count;
        }  
        addr[i] = _addr;
        index[_addr] = i;
    }
    
    function set(address _addr, uint _decimals, string _symbol, string _name) onlyOwner {
        link(_addr);
        decimals[_addr] = _decimals;
        symbol[_addr] = _symbol;
        name[_addr] = _name;
    }

    function getAddress(address _addr) constant returns(uint _decimals, string _symbol, string _name) {
        _decimals = decimals[_addr];
        _symbol = symbol[_addr];
        _name = name[_addr];
    }
    
    function getIndex(uint _index) constant returns(address _addr, uint _decimals, string _symbol, string _name) {
        _addr = addr[_index];
        _decimals = decimals[_addr];
        _symbol = symbol[_addr];
        _name = name[_addr];
    }
    
    function setExtra(address _addr, bytes32 id, string data) {
        extra[_addr][id] = data;
    }
    
    function getExtra(address _addr, bytes32 id) constant returns (string data) {
        data = extra[_addr][id];
    }
}