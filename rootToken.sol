pragma solidity ^0.4.12;

// Tool to generate the root hash of 100K records and display the proof for 2 of them:
// https://gist.github.com/JonnyLatte/5d72bec5bc708a0be61b3d3b15eadbb3


import "github.com/JonnyLatte/MiscSolidity/appToken.sol";

contract rootBase  {

    bytes32 public roothash;
    mapping(bytes32 => bool) used;

    function prove(bytes32[] hashes, bool[] parity, bytes32 subject) constant public returns(bool valid)  {
        bytes32 h = subject; 
        for(uint i = 0; i < hashes.length; i++) {
            if(parity[i]) h = keccak256(h        ,hashes[i]);
            else          h = keccak256(hashes[i],h        );
        }
        return (h == roothash && used[subject] == false);
    }
}

contract rootToken is rootBase, appToken 
{
    function rootToken(bytes32 _roothash) public 
    {
        roothash = _roothash;
    }

    function processClaim(bytes32[] hashes, bool[] parity, address target, uint256 value) public returns (bool ok)
    {
        var subject = keccak256(target, value);
        
        if(prove(hashes,parity,subject)) {
            used[subject] = true;
            issueTokens(target, value);
            return true;
        }
    }
    
   
    function checkProcessClaim(bytes32[] hashes, bool[] parity, address target, uint256 value) public constant returns (bool ok)
    {
        var subject = keccak256(target, value);
        
        if(prove(hashes,parity,subject)) {
           // used[subject] = true;
            //issueTokens(target, value);
            return true;
        }
    }
}
