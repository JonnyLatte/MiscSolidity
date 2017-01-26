pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/multiToken.sol";
import "github.com/JonnyLatte/MiscSolidity/verySig.sol";

contract stFundManager is fundManager, verySig {
    
    function signedTransfer(address token, address from, address to, uint256 value, uint256 expires, bytes sig) returns (bool ok)
    {
        if(now > expires) throw;
        if(from != msg.sender) throw;
        if(checkSig(sha3(token, from, to, value, expires), sig) != from) throw;
        
        appTransfer(token,from,to,value); 
        
        return true;
    }
}
