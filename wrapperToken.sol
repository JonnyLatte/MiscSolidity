
pragma solidity ^0.4.8;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";

contract wrapperToken is baseToken {
    
    function deposit() payable returns (bool ok) {
        _balances[msg.sender] = safeAdd(_balances[msg.sender],msg.value);
        _supply = safeAdd(_supply,msg.value);
        return true;
    }
    
    function withdraw(uint256 value) returns (bool ok) {
        _balances[msg.sender] = safeSub(_balances[msg.sender],value);
        _supply = safeSub(_supply,value);
        
        if(!msg.sender.send(value)) throw;
        
        return true; 
    }
    
    function() payable { 
        deposit();
    }
}
