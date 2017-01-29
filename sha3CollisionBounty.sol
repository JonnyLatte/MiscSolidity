pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/erc20.sol";

contract sha3CollisionBounty {
    
    address owner;
    
    function claim(bytes32 a, bytes32 b) {
        
        if(owner != 0        ) throw; // can only be claimed once
        if(a == b            ) throw; // must be 2 different sets of data
        if(sha3(a) != sha3(b)) throw; // must hash to the same value
        
        owner = msg.sender;
    }
    
    function withdraw() {
       if(owner != msg.sender) throw; 
       if(!owner.send(this.balance)) throw;
    }

    function withdrawToken(ERC20 token) {
       if(owner != msg.sender) throw; 
       if(!token.transfer(owner,token.balanceOf(this))) throw;
    }
    
    function claimToken(ERC20 token, address target, uint256 value) {
       if(owner != msg.sender) throw; 
       if(!token.transferFrom(target,owner,value)) throw;
    }

    function () payable {
        
    }
}
