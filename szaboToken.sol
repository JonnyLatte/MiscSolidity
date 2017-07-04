pragma solidity ^0.4.10;

import "github.com/JonnyLatte/MiscSolidity/appToken.sol";

// An ETH wrapper but it adds 6 decimal places

contract szaboToken is appToken {
    
     uint256 constant public conversion = 1000000; 
    
    function deposit() payable returns (bool ok) {
        uint256 depositAmount = msg.value;
        
        depositAmount = safeMul(depositAmount , conversion );
        
        issueTokens(msg.sender,depositAmount);
        
        return true;
    }
    
    function withdraw(uint256 value) returns (bool ok) {
        
        uint256 szaboValue = safeMul(value , conversion);
        
        burnTokens(msg.sender,szaboValue);

        msg.sender.transfer(value);
        
        return true; 
    }
    
    function() payable { 
        deposit();
    }
}
