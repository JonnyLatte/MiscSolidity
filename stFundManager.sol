pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/multiToken.sol";

contract verySig {
    
    function checkSig(bytes32 hash, bytes sig) internal returns(address) 
    {
        //https://gitter.im/ethereum/solidity/archives/2016/12/14
        
        uint8   v;
        bytes32 r;
        bytes32 s;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := and(mload(add(sig, 65)), 255)
        }
    
        if (v < 27) v += 27;
    
        return ecrecover(hash, v, r, s) ;
    }    
}


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
