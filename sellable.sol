pragma solidity ^0.4.4;

import "erc20.sol";
import "owned.sol";

contract ownedTokenBox is owned {
    
    // allows owner to deposit ETH
    // deposit tokens by sending them directly to contract
    // buyers must not send tokens to the contract, use: sell(...)
    function deposit() payable onlyOwner {
    }

    // allow owner to remove arbitrary tokens
    // included just in case contract receives wrong token
    function withdrawToken(address _token, uint256 _value) onlyOwner returns (bool ok)
    {
        return ERC20(_token).transfer(owner,_value);
    }

    // allow owner to remove ETH
    function withdraw(uint256 _value) onlyOwner returns (bool ok)
    {
        return owner.send(_value);
    }   
    
}

contract sellable is ownedTokenBox {
 
    bool public selling = false;
    uint public price;
    bool public lockedToRecipient;
    address public recipient;
    
    function initPrivateSale(uint _price, address _recipient) {
        price = _price;
        lockedToRecipient = true;
        recipient = _recipient;
    }
    
    function initPublicSale(uint _price) {
        price = _price;
        lockedToRecipient = false;
        recipient = 0;
    }
    
    function () {
        if(msg.value < price || (lockedToRecipient && msg.sender != recipient)) throw;
        if(msg.value > price) if(!msg.sender.send(msg.value - price)) throw;
        
        if(!owner.send(price)) throw; 
        
        owner = msg.sender;
        selling = false;
    }

}