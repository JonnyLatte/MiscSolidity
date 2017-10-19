pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol"; 
import "github.com/JonnyLatte/MiscSolidity/verySig.sol"; 

// base token that allows anyone to submit a transaction on behalf of an addres in return for a fee
// TODO: decoupled approval and transferFrom

contract decoupleToken is baseToken {
    
    using verySig for bytes32;
    
    mapping(address => mapping(uint => bool)) public usedNonce;
    
    function appTransfer(address from, address to, uint value) internal 
    {
        _balances[from]  = _balances[from].safeSub(value);              // will throw if inssufficient funds
        _balances[to]    = _balances[to].safeAdd(value);                // will throw if overflow
    }
    
    function getTranferHash(address from, address to, uint value, uint fee, uint nonce) public constant returns(bytes32) {
        return keccak256(this,from,to,value,fee,nonce);
    }
    
    function decoupledTransfer(address from, address to, uint value, uint fee, uint nonce, bytes sig) public {
        
        var hash = getTranferHash(from, to, value, fee, nonce);
        require(from == hash.checkSig(sig));
        
        if(usedNonce[from][nonce] == false)
        {
           usedNonce[from][nonce] = true;
           
           if(_balances[from] < fee) return; // return if cant pay fee
           appTransfer(from, msg.sender, fee); 
           
           if(_balances[from] < value) return; // return if cant pay
           appTransfer(from, to, value);       
        }
    }
}
