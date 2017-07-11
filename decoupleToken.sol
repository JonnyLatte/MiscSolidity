pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol"; 
import "github.com/JonnyLatte/MiscSolidity/verySig.sol"; 

// base token that allows anyone to submit a transaction on behalf of an addres in return for a fee
// TODO: decoupled approval and transferFrom

contract decoupleToken is baseToken , verySig {
    
    mapping(address => mapping(uint => bool)) public usedNonce;
    
    function appTransfer(address from, address to, uint value) internal 
    {
        _balances[from]  = _balances[from].safeSub(value);              // will throw if inssufficient funds
        _balances[to]    = _balances[to].safeAdd(value);                // will throw if overflow
    }
    
    function getTranferHash(address from, address to, uint value, uint fee, uint nonce) constant returns(bytes32) {
        return sha3(this,from,to,value,fee,nonce);
    }
    
    function decoupledTransfer(address from, address to, uint value, uint fee, uint nonce, bytes sig) {
        
        var hash = getTranferHash(from, to, value, fee, nonce);
        if(from != checkSig(hash, sig)) throw;
        
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
