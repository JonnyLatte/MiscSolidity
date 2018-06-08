pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/rootToken.sol";
import "github.com/JonnyLatte/MiscSolidity/hashTools.sol";

// merkle root initialized erc20 token that allows anyone to process a claim for tokens and initialize the recipient address with ether 
// in return the account initializing the claim gets a reward in the contract tokens 
// reward and seed ether specified by the recipient of the claim with an off chain signature of the conditins
// usable for airdrops to non ethereum users (who dont have ether to process the claim themselves)
// better name suggestions would be appreciated.

contract noGasClaimRootToken is rootToken {
    
    constructor(bytes32 rootHash) public rootToken(rootHash) {
        
    }
    
    function processClaimEx(bytes32[] proof, address target, uint256 value, uint tokenReward, uint weiPayment,bytes sig) payable public {
        
        require(weiPayment == msg.value);
        require(tokenReward <= value);
        
        bytes32 hash = keccak256(abi.encodePacked(this,target,value,tokenReward,weiPayment));
        
        require(hashTools.checkSig(hash,sig) == target);
        
        require(processClaim(proof,target,value));
        
        burnTokens(target,tokenReward);
        issueTokens(msg.sender,tokenReward);
        
        target.transfer(msg.value);
    }
    
}
