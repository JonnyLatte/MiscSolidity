pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/erc20.sol";
import "github.com/JonnyLatte/MiscSolidity/SafeMath.sol";
import "github.com/JonnyLatte/MiscSolidity/verySig.sol";


// OTC market contract with offchain orderbook
// user funds are not locked into the contract
// clients must query the balance of the user making an offer and their approval amount 
// and take the minimum of this and the approvals for the particular trade 
// to get what is actually available for each offer.
// like with EtherDelta making an offer requires no gas other than token approvals
// expired offers require no gas,
// canceling early does reqire gas as the offchain order must be prevented from going onchain.
// unlike etherdelta this contract never takes custody of maker funds and does not take ether into itself
//
// I am using verySig which decodes v r and s values of the signature on chain and does the ecrecover returning the recovered address

contract otc {
    
    using SafeMath for uint;
    using verySig  for bytes32;
    
    mapping(address => mapping(bytes32 => uint)) public approvals;
    mapping(address => mapping(uint => bool)) public usedNonce;
   
    event onTrade(bytes32 priceHash, uint unitLots);
    
    function getPriceHash(ERC20 sellToken, uint sellUnits, ERC20 buyToken, uint buyUnits) constant returns (bytes32) {
       return sha3(sellToken, sellUnits, buyToken, buyUnits);
    }
    
    function approve(bytes32 priceHash, uint unitLots) {
        approvals[msg.sender][priceHash] = unitLots;
    }
    
    function blockApproval(bytes32 priceHash, uint nonce) {
        approvals[msg.sender][priceHash] = 0;
        usedNonce[msg.sender][nonce] = true;
    }

    function trade(address maker, uint unitLots, ERC20 sellToken, uint sellUnits, ERC20 buyToken, uint buyUnits) 
    {
        var priceHash = sha3(sellToken, sellUnits, buyToken, buyUnits);
        approvals[msg.sender][priceHash] = approvals[msg.sender][priceHash].safeSub(unitLots); // throws if maker does not approve
        
        require(sellToken.transferFrom(maker     ,msg.sender, unitLots.safeMul(sellUnits)));
        require(buyToken.transferFrom( msg.sender,maker     , unitLots.safeMul(buyUnits ))); 
        
        onTrade(priceHash,unitLots);
    }

    function approveAndtrade(bytes sig, uint nonce, uint approvedLots, address maker, uint unitLots, ERC20 sellToken, uint sellUnits, ERC20 buyToken, uint buyUnits) 
    {
        require(usedNonce[maker][nonce] == false);
        
        var priceHash = sha3(sellToken, sellUnits, buyToken, buyUnits);
        var sigHash   = sha3(priceHash,nonce,approvedLots);
        
        require(maker == sigHash.checkSig(sig));
        
        usedNonce[maker][nonce] = true;
        
        approvals[msg.sender][priceHash] = approvals[msg.sender][priceHash].safeSub(unitLots); // throws if maker does not approve
        
        require(sellToken.transferFrom(maker     ,msg.sender, unitLots.safeMul(sellUnits)));
        require(buyToken.transferFrom( msg.sender,maker     , unitLots.safeMul(buyUnits ))); 
        
        onTrade(priceHash,unitLots);
    }
}
