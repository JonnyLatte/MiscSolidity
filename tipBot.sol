
// ERC20 Tip bot contract.
//
// c) Jonnylatte, MIT licence
//

pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/erc20.sol"; 
import "github.com/JonnyLatte/MiscSolidity/verySig.sol"; 
import "github.com/JonnyLatte/MiscSolidity/owned.sol"; 

contract tipBot is owned, verySig {
    
    mapping(bytes32 => address) public user_accounts;
    mapping(bytes32 => bool) used_tip_hash;

    function getUserHash(string username, string service) constant returns (bytes32) {
        return sha3(username,service);
    }

    function getUserRegistrationHash(address user, bytes32 userHash) constant returns (bytes32) 
    {
        return sha3(this,user, userHash);
    }
    
    function registerAccount(address user, bytes32 userHash, bytes tipBotSig) 
    {
        var hash = getUserRegistrationHash(user, userHash);
        if(owner != checkSig(hash,tipBotSig) ) throw;
        
        user_accounts[userHash] = user;
    }
    
    function getTipHash(address tipper,  bytes32 receiver, address token, uint256 value, uint256 expiry) constant returns (bytes32) 
    {
        return sha3(this,tipper,receiver, value, expiry);
    }
    
    function claimTip(address tipper, bytes32 receiver, address token, uint256 value, uint256 expiry, bytes tipperSig) 
    {
          if(now > expiry) throw;                   // tip must not be expired
          if(user_accounts[receiver] == 0) throw;   // receiver must be registered
          
          var hash = getTipHash(tipper, receiver,  token,  value,  expiry);  
          
          if(tipper != checkSig(hash,tipperSig)) throw; // sender must have signed the tip
          
          if(used_tip_hash[hash]) throw; // the same tip can only be claimed once. Increment expiry to generate new hash 
          used_tip_hash[hash] = true;
          
          if(!ERC20(token).transferFrom(tipper,user_accounts[receiver], value)) throw; // attempt to transfer funds from tipper to receiver
    }
}
