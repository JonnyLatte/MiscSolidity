pragma solidity ^0.4.4;

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
