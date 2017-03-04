pragma solidity ^0.4.8;

contract Token {
    function transferFrom( address from, address to, uint value) returns (bool ok);
}

contract miniOTC {
    
    Token   public maker_buy_token;
    uint256 public maker_buy_units;
    Token   public maker_sell_token;
    uint256 public maker_sell_units;
    
    event onTrade(uint256 unitLots);
    
    function  miniOTC(Token _maker_buy_token, uint256 _maker_buy_units, Token _maker_sell_token, uint256 _maker_sell_units) 
    {
       maker_buy_token   = _maker_buy_token;
       maker_buy_units   = _maker_buy_units; 
       maker_sell_token  = _maker_sell_token; 
       maker_sell_units  = _maker_sell_units; 
    }
    
    function assert(bool assertion) internal {
       if (!assertion) throw;  
    }

    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    
    function trade(address maker, uint256 unitLots) 
    {
        if(!maker_buy_token.transferFrom(msg.sender,maker,safeMul(unitLots, maker_buy_units))) throw;
        if(!maker_sell_token.transferFrom(maker,msg.sender,safeMul(unitLots, maker_sell_units))) throw;
        onTrade(unitLots);
    }
}

contract miniOTCFactory {
    
    event tradeListing(address contractAddress, Token indexed _maker_buy_token, uint256 _maker_buy_units, Token indexed _maker_sell_token, uint256 _maker_sell_units);
    
    function  createTrade(Token _maker_buy_token, uint256 _maker_buy_units, Token _maker_sell_token, uint256 _maker_sell_units) 
    {
        tradeListing(
            new miniOTC(_maker_buy_token, _maker_buy_units, _maker_sell_token, _maker_sell_units) , 
            _maker_buy_token, 
            _maker_buy_units, 
            _maker_sell_token, 
            _maker_sell_units);       
    }
}
