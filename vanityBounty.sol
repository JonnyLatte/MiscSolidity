
/*

WARNING: work in progress

This contract is in the process of being designed and is likely to be in an incomplete and non functional state

JonnyLatte 2017, MIT licence all the things

*/

pragma solidity ^0.4.8;

import "github.com/jbaylina/ecsol/ec.sol"; 

contract vanityBounty {
    
    EC ec = EC(0x014c2e29Ee6781bc854627bc04C29Cfc45bBD5Ac); // testnet EC contract
    
    struct CHALLANGE 
    {
        address owner;
        uint256 expiry;
        uint256 reward;
        bytes20 mask;
        bytes20 target;
        uint256 qx;
        uint256 qy;
        uint256 offsetKey;
    }
    
    uint256 public last_challange_id;
    mapping(uint => CHALLANGE) challanges;
    
    function getChallangeID() returns (uint256) {
        last_challange_id++;
        return last_challange_id;
    }
    
    function makeChallange(uint256 qx, uint qy, bytes20 mask, bytes20 target, uint256 timeLimit) payable 
    {
         challanges[getChallangeID()] = CHALLANGE
                                        (msg.sender,
                                         now+timeLimit,
                                         msg.value,
                                         mask,
                                         target,
                                         qx,
                                         qy,
                                         0);
    }
    
    function getChallange(uint256 challangeID) constant returns (
        address owner,
        uint256 expiry,
        uint256 reward,
        bytes20 mask,
        bytes20 target,
        uint256 qx,
        uint256 qy,
        uint256 offsetKey)
    {
        owner     = challanges[challangeID].owner;
        expiry    = challanges[challangeID].expiry;
        reward    = challanges[challangeID].reward;
        mask      = challanges[challangeID].mask;
        target    = challanges[challangeID].target;
        qx        = challanges[challangeID].qx;
        qy        = challanges[challangeID].qy;
        offsetKey = challanges[challangeID].offsetKey;
    }

    function getOffsetKey(address addr, uint256 nonce) constant returns (uint256) 
    {
        return uint256(sha256(addr,nonce));
    }
    
    function pub2hash(uint256 qx, uint qy)  constant returns (bytes20) 
    {
       return ripemd160(sha256("\x04",qx,qy)); 
    }
  
    function challangeHash(uint256 nonce, uint256 challangeID) constant returns (bytes20) 
    {
           var offsetKey = getOffsetKey(msg.sender,nonce);
           var (qx,qy) = ec.deriveKey(offsetKey,challanges[challangeID].qx,challanges[challangeID].qy);
           return pub2hash(qx,qy);
    }
    
    function claimReward(address addr, uint256 nonce, uint256 challangeID) 
    {
        if(challanges[challangeID].offsetKey != 0)  return;
        
        var offsetKey  = getOffsetKey(addr,nonce);
        var (qx,qy)    = ec.deriveKey(offsetKey,challanges[challangeID].qx,challanges[challangeID].qy);
        var hashResult = pub2hash(qx,qy);
        
        if( (hashResult & challanges[challangeID].mask) > challanges[challangeID].target) throw;
        challanges[challangeID].offsetKey = offsetKey;
        
        if(!addr.send(challanges[challangeID].reward)) throw;
    }
    
    function cancelChallange(uint256 challangeID) 
    {
        if(challanges[challangeID].offsetKey != 0)  return;         // funds already claimed
        if(msg.sender != challanges[challangeID].owner) throw;      // must be owner
        if(now < challanges[challangeID].expiry) throw;             // must have expired
        if(!msg.sender.send(challanges[challangeID].reward)) throw; // must receive funds
        delete challanges[challangeID];
    }
}
