pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/owned.sol";

contract sellable is owned {
    
    bool public selling;
    uint public price;
    uint public nonce; 
    
    event onSale(uint price);
    event onCancelSale();
    event onTrade();
    event onExecute(address _to, uint _value, bytes _data);
    
    function sellable() public {
        selling = false;
    }
    
    function initSale(uint _price) public onlyOwner 
    {
        nonce++;
        price = _price;
        selling = true;
        
        onSale(price);
    }
    
    function cancelSale() public  onlyOwner {
        selling = false;
        onCancelSale();
    }
    
    function takerBuys(uint _nonce) public payable 
    {
        if(_nonce != nonce || !selling) return; // contract no longer selling
        require(msg.value == price);
        selling = false; // prevent sale after ownership transfer
        address seller = owner; // store seller address so that contract state can be updated before external call
        owner = msg.sender; // update owner
        seller.transfer(msg.value); // pay seller
        onTrade();
    }
    
    function execute(address _to, uint _value, bytes _data) public onlyOwner returns (bool) 
    {
        if(selling) cancelSale(); // interacting with contract during sale period canceles sale
        onExecute(
            _to, 
            _value, 
            _data         
            );
        return _to.call.value(_value)(_data); // call contracts / transfer ETH 
    }
}
