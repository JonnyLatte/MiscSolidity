pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/optionToken.sol"; 

// optionFactory: create single use option tokens
//
// TODO: comments, events

contract optionFactory {
    
    uint256 last_option_id;
    mapping(uint256 => optionToken) public options;
    mapping(address => bool) _valid;
    
    function next_option_id() internal returns (uint) {
        last_option_id++;
        return last_option_id;
    }
    
    function createOptionToken(
        address _currency, 
        address _asset, 
        uint256 _price, 
        uint256 _units, 
        uint256 _duration) returns (optionToken) 
    {
        var token = new optionToken(
         _currency, 
         _asset, 
         _price, 
         _units, 
         _duration);     
         
        if(!token.transferOwnership(msg.sender)) throw;
        
        var id = next_option_id();
        options[id] = token;
        _valid[token] = true;
        
        return token;
    }
    
    function verify(optionToken addr) constant returns 
    (
        bool    valid,
        address option_owner,
        address option_currency, 
        address option_asset, 
        uint256 option_price, 
        uint256 option_units, 
        uint256 option_expireTime)
    {
        valid  = _valid[addr];
        
        option_owner      = optionToken(addr).owner();
        option_currency   = optionToken(addr).currency();
        option_asset      = optionToken(addr).asset();
        option_price      = optionToken(addr).price();
        option_units      = optionToken(addr).units();
        option_expireTime = optionToken(addr).expireTime();
    }
}
