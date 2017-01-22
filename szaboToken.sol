pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";

// An ETH wrapper but it adds 6 decimal places

contract szaboToken is baseToken {
    
     uint256 constant public conversion = 1000000; 
    
    function deposit() payable returns (bool ok) {
        uint256 depositAmount = msg.value;
        
        depositAmount = depositAmount * conversion;
        
        if (depositAmount < conversion) throw;
        if (_balances[msg.sender] + depositAmount < depositAmount) throw;
        
        _balances[msg.sender] += depositAmount;
        _supply += depositAmount;
        return true;
    }
    
    function withdraw(uint256 value) returns (bool ok) {
        
        uint256 szaboValue = value * conversion;
        
        if(szaboValue < value) throw;
        
        if (_balances[msg.sender] < szaboValue) throw;
        _balances[msg.sender] -= szaboValue;
        _supply -= szaboValue;
        
        if(!msg.sender.send(value)) throw;
        
        return true; 
    }
    
    function() payable { 
        deposit();
    }
}
