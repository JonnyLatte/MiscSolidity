pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/appToken.sol";

//helper:
//https://github.com/JonnyLatte/MiscSolidity/blob/master/rootProof.js

library rootLib {
    
    function getRoot(bytes32 leaf,bytes32[] proof) constant public returns(bytes32 root)  {
        bytes32 h = leaf; 
        for(uint i = 0; i < proof.length; i++) {
            if(h > proof[i]) h = keccak256(h        ,proof[i]);
            else             h = keccak256(proof[i],h        );
        }
        return h;
    }
    
    function prove(bytes32 leaf,bytes32[] proof, bytes32 root) constant public returns (bool valid)  {
        return (root == getRoot(leaf,proof));
    }
    
}

contract rootBase  {
    
    using rootLib for bytes32;

    mapping(bytes32 => bool) public roothashes;
   
    event onRootHash(bytes32 hash, bool valid);
    
    function setRoot(bytes32 hash, bool valid) internal {
        roothashes[hash] = valid;
        onRootHash(hash,valid);
    }

    function prove(bytes32[] proof, bytes32 leaf) constant public returns(bool valid)  {
        return roothashes[leaf.getRoot(proof)];
    }
}

contract rootToken is rootBase, appToken 
{ 
    mapping(bytes32 => bool) public used;
    
    function rootToken(bytes32 _roothash) public 
    {
        setRoot(_roothash,true);
    }

    function processClaim(bytes32[] proof, address target, uint256 value) public returns (bool ok)
    {
        var leaf = keccak256(target, value);
        
        if(used[leaf] == false && prove(proof,leaf)) {
            used[leaf] = true;
            issueTokens(target, value);
            return true;
        }
    }
    
   
    function checkProcessClaim(bytes32[] proof, address target, uint256 value) public constant returns (bool ok)
    {
        var leaf = keccak256(target, value);
        
        if(prove(proof,leaf)) {
            return true;
        }
    }
}
