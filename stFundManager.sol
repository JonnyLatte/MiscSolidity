pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/multiToken.sol";
import "github.com/JonnyLatte/MiscSolidity/verySig.sol";

contract stFundManager is fundManager {
    
    using verySig for bytes32;
    
    function signedTransfer(address token, address from, address to, uint256 value, uint256 expires, bytes sig) public returns (bool ok)
    {
        require(block.timestamp <= expires);
        require(from == msg.sender);
        require(keccak256(token, from, to, value, expires).checkSig(sig) == from);
        
        appTransfer(token,from,to,value); 
        
        return true;
    }
}
