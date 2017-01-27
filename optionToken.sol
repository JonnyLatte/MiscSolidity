pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/appToken.sol"; 
import "github.com/JonnyLatte/MiscSolidity/owned.sol"; 

contract optionToken is appToken, ownedWithAproval {
    
    address public currency;   // Token used to buy
    address public asset;      // Token on offer
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
        address _currency, 
        address _asset, 
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
        if(!ERC20(asset).transferFrom(msg.sender, address(this),value)) throw; 
        issueTokens(msg.sender,value);
        return true;
    }

    // at any time owner can release funds by controlling the corrisponding option
    // which will be burned.
    
    function burnOptions(uint256 unit_lots)  
        onlyOwner
        returns (bool ok)
    {
        var value = safeMul(units,unit_lots);
        burnTokens(msg.sender,value);
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
        return ERC20(currency).transfer(msg.sender,_value);
    }
    
    // option holder buys asset
    function exercise(uint256 unit_lots) 
        onlyBeforeExpire
        returns (bool ok)       
    {
        var value = safeMul(units,unit_lots);
        var payment = safeMul(price,unit_lots);
        
        burnTokens(msg.sender,value);
        if(!ERC20(currency).transferFrom(msg.sender, address(this),payment)) throw; 
        if(!ERC20(asset).transfer(msg.sender,value)) throw; 
        return true;
    } 
}
