pragma solidity ^0.4.8;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract sellable is owned {
    
    bool public selling;
    uint public price;
    uint public nonce; 
    
    event onSale(uint price);
    event onCancelSale();
    event onTrade();
    event onExecute(address _to, uint _value, bytes _data);
    
    function sellable() {
        selling = false;
    }
    
    function initSale(uint _price) onlyOwner 
    {
        nonce++;
        price = _price;
        selling = true;
        
        onSale(price);
    }
    
    function cancelSale() onlyOwner {
        selling = false;
        onCancelSale();
    }
    
    function takerBuys(uint _nonce) payable 
    {
        if(_nonce != nonce || !selling) return; // contract no longer selling
        if(msg.value != price) throw;
        selling = false; // prevent sale after ownership transfer
        address seller = owner; // store seller address so that contract state can be updated before external call
        owner = msg.sender; // update owner
        if(!seller.send(msg.value)) throw; // pay seller
        onTrade();
    }
    
    function execute(address _to, uint _value, bytes _data) onlyOwner returns (bool) 
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
