pragma solidity ^0.4.4;

import "baseToken.sol";

contract wrapperToken is baseToken {
    
    function deposit() payable returns (bool ok) {
        if (_balances[msg.sender] + msg.value < _balances[msg.sender]) throw;
        _balances[msg.sender] += msg.value;
        _supply += msg.value;
        return true;
    }
    
    function withdraw(uint256 value) returns (bool ok) {
        if (_balances[msg.sender] < value) throw;
        _balances[msg.sender] -= value;
        _supply -= value;
        
        if(!msg.sender.send(value)) throw;
        
        return true; 
    }
    
    function() payable { 
        if (_balances[msg.sender] + msg.value < _balances[msg.sender]) throw;
        _balances[msg.sender] += msg.value;
        _supply += msg.value;
    }

    
}