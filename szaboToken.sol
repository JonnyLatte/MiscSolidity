pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/appToken.sol";

// An ETH wrapper but it adds 6 decimal places

contract szaboToken is appToken {
    
     uint256 constant public conversion = 1000000; 
    
    function deposit() payable returns (bool ok) {
        uint256 depositAmount = msg.value;
        
        depositAmount = depositAmount * conversion;
        
        issueTokens(msg.sender,depositAmount);
        
        return true;
    }
    
    function withdraw(uint256 value) returns (bool ok) {
        
        uint256 szaboValue = value * conversion;
        
        burnTokens(msg.sender,szaboValue);

        if(!msg.sender.send(value)) throw;
        
        return true; 
    }
    
    function() payable { 
        deposit();
    }
}
