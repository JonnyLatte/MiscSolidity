pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/SafeMath.sol";
import "github.com/JonnyLatte/MiscSolidity/erc20.sol";

contract miniOTC {
    
    using SafeMath for uint;
    
    ERC20   public maker_buy_token;
    uint256 public maker_buy_units;
    ERC20   public maker_sell_token;
    uint256 public maker_sell_units;

    event onTrade(uint256 unitLots);
    
    function  miniOTC(ERC20 _maker_buy_token, uint256 _maker_buy_units, ERC20 _maker_sell_token, uint256 _maker_sell_units) public
    {
       maker_buy_token    = _maker_buy_token;
       maker_buy_units    = _maker_buy_units; 
       maker_sell_token   = _maker_sell_token; 
       maker_sell_units   = _maker_sell_units; 
    }

    function trade(address taker, address maker, uint256 unitLots) public
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
    
    function  createTrade(ERC20 _maker_buy_token, uint256 _maker_buy_units, ERC20 _maker_sell_token, uint256 _maker_sell_units) public
    {
        tradeListing(
            new miniOTC(_maker_buy_token, _maker_buy_units, _maker_sell_token, _maker_sell_units) , 
            _maker_buy_token, 
            _maker_buy_units, 
            _maker_sell_token, 
            _maker_sell_units);       
    }
}
