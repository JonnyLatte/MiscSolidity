pragma solidity ^0.4.12;


library hashTools {
  
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
}

