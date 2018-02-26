pragma solidity ^0.4.12;


library verySig {
  
    // reverse the bytes of a byte32 value
    function reverseBytes32(bytes32 x) internal pure returns (bytes32) {
        for(uint i = 0; i < 32; i++) {        
            assembly {
                mstore8(i,x) 
                x := div(x,256)            
            }
        }
        assembly {
            return(0x0, 32)
        }
    }
    
    
    // recover address from signature data
    function checkSig(bytes32 hash, bytes sig) internal pure returns(address) 
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
