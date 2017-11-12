pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/appToken.sol";

contract rootBase  {

    mapping(bytes32 => bool) public roothashes;
    mapping(bytes32 => bool) public used;
    
    event onRootHash(bytes32 hash, bool valid);
    
    function setRoot(bytes32 hash, bool valid) internal {
        roothashes[hash] = valid;
        onRootHash(hash,valid);
    }

    function prove(bytes32[] hashes, bytes32 subject) constant public returns(bool valid)  {
        bytes32 h = subject; 
        for(uint i = 0; i < hashes.length; i++) {
            if(h > hashes[i]) h = keccak256(h        ,hashes[i]);
            else              h = keccak256(hashes[i],h        );
        }
        return (roothashes[h] && used[subject] == false);
    }
}

contract rootToken is rootBase, appToken 
{
    function rootToken(bytes32 _roothash) public 
    {
        setRoot(_roothash,true);
    }

    function processClaim(bytes32[] hashes, address target, uint256 value) public returns (bool ok)
    {
        var subject = keccak256(target, value);
        
        if(prove(hashes,subject)) {
            used[subject] = true;
            issueTokens(target, value);
            return true;
        }
    }
    
   
    function checkProcessClaim(bytes32[] hashes, address target, uint256 value) public constant returns (bool ok)
    {
        var subject = keccak256(target, value);
        
        if(prove(hashes,subject)) {
           // used[subject] = true;
            //issueTokens(target, value);
            return true;
        }
    }
}
