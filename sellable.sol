pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/erc20.sol";
import "github.com/JonnyLatte/MiscSolidity/owned.sol";


contract sellable is owned {
 
    bool public selling = false;
    uint public price;
    bool public lockedToRecipient;
    address public recipient;
    bool public locked = false;
    uint public lockTime;
    
    uint public lockInterval = 60*60*3; //3 hours
    
    modifier lockIfSelling() {
        
        if(selling && !locked) {
            locked = true;
            lockTime = now + lockInterval;
        }   
        
        _;
    }
    
    modifier throwIfLocked() {
        if(locked) throw;
        _;
    }
    
    function unlock() {
        if(now > lockTime) {
            locked = false;
            selling = false;
        }
    }
    
    // allows owner to deposit ETH
    // deposit tokens by sending them directly to contract
    // buyers must not send tokens to the contract, use: sell(...)
    function deposit() payable onlyOwner {
    }

    // allow owner to remove arbitrary tokens
    // included just in case contract receives wrong token
    function withdrawToken(address _token, uint256 _value) 
        onlyOwner 
        lockIfSelling returns (bool ok)
    {
        return ERC20(_token).transfer(owner,_value);
    }

    // allow owner to remove ETH
    function withdraw(uint256 _value) 
        onlyOwner
        lockIfSelling
        returns (bool ok)
    {
        return owner.send(_value);
    }   
    
    function initPrivateSale(uint _price, address _recipient) 
        throwIfLocked
        lockIfSelling
    {
        price = _price;
        lockedToRecipient = true;
        recipient = _recipient;
    }
    
    function initPublicSale(uint _price)
        throwIfLocked
        lockIfSelling
    {
        price = _price;
        lockedToRecipient = false;
        recipient = 0;
    }
    
    function () throwIfLocked {
        if(msg.value < price || (lockedToRecipient && msg.sender != recipient)) throw;
        if(msg.value > price) if(!msg.sender.send(msg.value - price)) throw;
        
        address benefactor = owner; 
         
        owner = msg.sender;
        selling = false;
        
        // must happen last so that ownership is updated before
        //passing control externally with send()
        
        if(!benefactor.send(price)) throw; 
    }

}
