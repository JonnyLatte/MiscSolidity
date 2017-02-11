pragma solidity ^0.4.8;

contract Token {
    function transferFrom( address from, address to, uint value) returns (bool ok);
}

contract miniOTC {
    
    Token   public maker_buy_token;
    uint256 public maker_buy_units;
    Token   public maker_sell_token;
    uint256 public maker_sell_units;
    
    function  miniOTC(Token _maker_buy_token, uint256 _maker_buy_units, Token _maker_sell_token, uint256 _maker_sell_units) 
    {
       maker_buy_token   = _maker_buy_token;
       maker_buy_units   = _maker_buy_units; 
       maker_sell_token  = _maker_sell_token; 
       maker_sell_units  = _maker_sell_units; 
    }
    
    function trade(address maker, uint256 unitLots) 
    {
        if(!maker_buy_token.transferFrom(msg.sender,maker,unitLots * maker_sell_units)) throw;
        if(!maker_sell_token.transferFrom(maker,msg.sender,unitLots * maker_buy_units)) throw;
    }
}

contract miniOTCFactory {
    
    event tradeListing(address contractAddress, Token _maker_buy_token, uint256 _maker_buy_units, Token _maker_sell_token, uint256 _maker_sell_units);
    
    function  createTradeMicro (Token _maker_buy_token, uint256 _maker_buy_units, Token _maker_sell_token, uint256 _maker_sell_units) 
    {
        tradeListing(
            new miniOTC(_maker_buy_token, _maker_buy_units, _maker_sell_token, _maker_sell_units) , 
            _maker_buy_token, 
            _maker_buy_units, 
            _maker_sell_token, 
            _maker_sell_units);       
    }  
}
