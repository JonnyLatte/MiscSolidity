pragma solidity ^0.4.10;

contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
    function totalSupply() constant returns (uint supply);
    function balanceOf( address who ) constant returns (uint value);
    function allowance(address owner, address spender) constant returns (uint _allowance);   
    function transfer( address to, uint value) returns (bool ok);
    function transferFrom( address from, address to, uint value) returns (bool ok);
    function approve(address spender, uint value) returns (bool ok);
}


library SafeMath 
{
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


contract miniOTC {
    
    using SafeMath for uint;
    
    ERC20   public maker_buy_token;
    uint256 public maker_buy_units;
    ERC20   public maker_sell_token;
    uint256 public maker_sell_units;

    event onTrade(uint256 unitLots);
    
    function  miniOTC(ERC20 _maker_buy_token, uint256 _maker_buy_units, ERC20 _maker_sell_token, uint256 _maker_sell_units) 
    {
       maker_buy_token    = _maker_buy_token;
       maker_buy_units    = _maker_buy_units; 
       maker_sell_token   = _maker_sell_token; 
       maker_sell_units   = _maker_sell_units; 
    }

    function trade(address taker, address maker, uint256 unitLots)
    {
        uint takerValue = unitLots.safeMul(maker_buy_units);
        uint makerValue = unitLots.safeMul(maker_sell_units);
        require(maker_buy_token.transferFrom(taker,maker,takerValue)); // pay maker
        require(maker_sell_token.transferFrom(maker,taker,makerValue));// pay taker
        onTrade(unitLots);
    }
}

contract miniOTCFactory {
    
    event tradeListing(address contractAddress, ERC20 indexed _maker_buy_token, uint256 _maker_buy_units, ERC20 indexed _maker_sell_token, uint256 _maker_sell_units);
    
    function  createTrade(ERC20 _maker_buy_token, uint256 _maker_buy_units, ERC20 _maker_sell_token, uint256 _maker_sell_units) 
    {
        tradeListing(
            new miniOTC(_maker_buy_token, _maker_buy_units, _maker_sell_token, _maker_sell_units) , 
            _maker_buy_token, 
            _maker_buy_units, 
            _maker_sell_token, 
            _maker_sell_units);       
    }
}
