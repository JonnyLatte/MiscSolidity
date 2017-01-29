pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/appToken.sol";

// rootToken is initialized with a root hash which is added to a mapping validHash
// any hash in validHash is either a claim or a node
// a node is a sha3 hash of 2 hashes that can be added to the validHash mapping using addNode()
// a claim is a sha3 hash of an address and uint256 balance
// calling processClaim() issues tokens to 
//
// Jonnylatte, MIT licence

contract rootToken is appToken {
    
    bytes32 public rootHash;
    mapping(bytes32 => bool) public validHash;
    mapping(bytes32 => bool) public claimedHash;
    
    function rootToken(bytes32 _rootHash) {
        rootHash = _rootHash;
        validHash[_rootHash] = true;
    }
    
    function hashNode(bytes32 left, bytes32 right) constant returns (bytes32) 
    {
        return sha3(left,right);
    }  
    
    function hashClaim(address target, uint256 value) constant returns (bytes32) 
    {
        return sha3(target,value);
    }    
    
    function validNode(bytes32 left, bytes32 right) constant returns (bool ok)
    {
        return validHash[hashNode(left,right)];
    }
    
    function validClaim(address target, uint256 value) constant returns (bool ok)
    {
        return validHash[hashClaim(target, value)];
    }
    
    function addNode(bytes32 left, bytes32 right) returns (bool ok)
    {
        if(!validNode(left,right)) throw;

        validHash[left] = true;
        validHash[right] = true;
        return true;
    }

    function processClaim(address target, uint256 value)  returns (bool ok)
    {
        var hash = hashClaim(target, value);
        if(validHash[hash] == false) throw;
        if(claimedHash[hash] == true) throw;
        claimedHash[hash] = true;
        issueTokens(target, value);
        return true;
    }
}
