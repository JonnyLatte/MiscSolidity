pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";

contract wrapperToken is baseToken {
    
    function deposit() payable returns (bool ok) {
        _balances[msg.sender] = _balances[msg.sender].safeAdd(msg.value);
        _supply = _supply.safeAdd(msg.value);
        return true;
    }
    
    function withdraw(uint value) returns (bool ok) {
        _balances[msg.sender] = _balances[msg.sender].safeSub(value);
        _supply = _supply.safeSub(value);
        
        msg.sender.transfer(value);
        
        return true; 
    }
    
    function() payable { 
        deposit();
    }
}
