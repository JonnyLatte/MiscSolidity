pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/appToken.sol"; 
import "github.com/JonnyLatte/MiscSolidity/owned.sol"; 

contract optionToken is appToken, ownedWithAproval {
    
    ERC20 public currency;   // Token used to buy
    ERC20 public asset;      // Token on offer
    uint256 public price;      // Amount of currency needed to buy a lot (smallest units)
    uint256 public units;      // Amount of asset being sold in a lot (smallest units)
    uint256 public expireTime;  // trading ends at this timestamp
    
    modifier onlyBeforeExpire() 
    {
        if(now < expireTime) _;
        else throw;
    }
    
    modifier onlyAfterExpire() 
    {
        if(now > expireTime) _;
        else throw;
    }
    
    function optionToken(
        ERC20 _currency, 
        ERC20 _asset, 
        uint256 _price, 
        uint256 _units, 
        uint256 _duration) 
    {
        currency = _currency;
        asset = _asset;
        price = _price;
        units = _units;
        expireTime = now + _duration;       
    }
    
    // seller locks asset and is given a token representing the option to buy it
    function issueOptions(uint256 unit_lots)  
        onlyOwner
        returns (bool ok)
    {
        var value = safeMul(units,unit_lots);
        if(!asset.transferFrom(msg.sender, address(this),value)) throw; 
        issueTokens(msg.sender,unit_lots);
        return true;
    }

    // at any time owner can release funds by controlling the corrisponding option
    // which will be burned.
    
    function burnOptions(uint256 unit_lots)  
        onlyOwner
        returns (bool ok)
    {
        var value = safeMul(units,unit_lots);
        burnTokens(msg.sender,unit_lots);
        if(!ERC20(asset).transfer(msg.sender,value)) throw; 
        return true;
    }
    
    // after expiry owner can release any funds
    function withdrawToken(address _token, uint256 _value)
        onlyOwner
        onlyAfterExpire
        returns (bool ok)
    {
        return ERC20(_token).transfer(msg.sender,_value);
    }
    
    // currency does not need to be locked 
    function withdrawCurrency(uint256 _value)
        onlyOwner
        returns (bool ok)
    {
        return currency.transfer(msg.sender,_value);
    }
    
    function claimFundsAndDestroyContract()   
        onlyOwner
        onlyAfterExpire
        returns (bool ok)
    {
        uint256 asset_balance = asset.balanceOf(this);
        uint256 currency_balance = currency.balanceOf(this);
        
        if(!asset.transfer(owner,asset_balance)) throw;
        if(!currency.transfer(owner,currency_balance)) throw;
        
        suicide(owner);
    }
    
    // option holder buys asset
    function exercise(uint256 unit_lots) 
        onlyBeforeExpire
        returns (bool ok)       
    {
        var value = safeMul(units,unit_lots);
        var payment = safeMul(price,unit_lots);
        
        burnTokens(msg.sender,unit_lots);
        if(!currency.transferFrom(msg.sender, address(this),payment)) throw; 
        if(!asset.transfer(msg.sender,unit_lots)) throw; 
        return true;
    } 
}
