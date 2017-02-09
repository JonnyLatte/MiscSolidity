pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/ownedToken.sol";

contract optionFactory 
{
    struct OPTION_INFO 
    {
        address    owner;
        ERC20      sell_token;
        uint       sell_units;
        ERC20      buy_token;
        uint       buy_units;
        uint       expiry;
        ownedToken token;
    }
    
    uint public last_option_id;
    
    mapping(uint => OPTION_INFO) option_info;

    //--------------------------------------------------------------------------------

    event mintEvent(uint id, uint unitLots);
    event burnEvent(uint id, uint unitLots);
    event exerciseEvent(uint id, uint unitLots);
    event closeEvent(uint id);
    
    event optionCreatedEvent(
        uint id,
        address indexed owner,
        ERC20 indexed sell_token,
        uint  sell_units,
        ERC20 indexed buy_token,
        uint  buy_units,
        uint expiry,
        ERC20 token);

    //--------------------------------------------------------------------------------

    function next_option_id() internal returns (uint) 
    {
        return ++last_option_id;
    }    
    
    function create_option(        
        ERC20 sell_token,
        uint  sell_units,
        ERC20 buy_token,
        uint  buy_units,
        uint time_to_expiry) returns (uint id, ownedToken token)
    {
        id = next_option_id();
        token = new ownedToken();
        
        if(address(token) == 0) throw;
        
        var expiry = now + time_to_expiry;
        
        option_info[id] = OPTION_INFO (
            msg.sender,
            sell_token,
            sell_units,
            buy_token,
            buy_units,
            expiry,
            token);
            
        optionCreatedEvent(id,msg.sender,sell_token, sell_units,buy_token,buy_units,expiry,token);
    }
    
    function optionInfo(uint id) constant returns(
        address owner,
        ERC20 sell_token,
        uint  sell_units,
        ERC20 buy_token,
        uint  buy_units,
        uint  expiry,
        uint  time_to_expiry,
        address token) 
    {
        var option = option_info[id];
        
        owner      = option.owner;
        sell_token = option.sell_token;
        sell_units = option.sell_units;
        buy_token  = option.buy_token;
        buy_units  = option.buy_units;
        expiry     = option.expiry;
        
        if(expiry > now) time_to_expiry = expiry - now;
        
        token = option.token;
    }
    
    function mint(uint id, uint unitLots) 
    {
        var option = option_info[id];
        
        if(option.owner != msg.sender) throw;
        
        if(!option.sell_token.transferFrom(msg.sender,this,unitLots*option.sell_units)) throw;
        option.token.issue(unitLots,msg.sender);
        
        mintEvent(id,unitLots);
    }
    
    function burn(uint id, uint unitLots) 
    {
        var option = option_info[id];
        
        if(option.owner != msg.sender) throw;
        
        if(!option.token.burn(unitLots,msg.sender)) throw;
        if(!option.sell_token.transfer(msg.sender,unitLots*option.sell_units)) throw;
        
        burnEvent(id,unitLots);
    }
    
    function exercise(uint id, uint unitLots) 
    {
        var option = option_info[id];
        
        if(option.expiry > now) throw;
        
        if(!option.token.burn(unitLots,msg.sender)) throw;
        if(!option.buy_token.transferFrom (msg.sender,option.owner,unitLots*option.buy_units )) throw;
        if(!option.sell_token.transferFrom(this      ,msg.sender  ,unitLots*option.sell_units)) throw;
        
        exerciseEvent(id,unitLots);
    }
    
    function close(uint id) 
    {
        var option = option_info[id];
        
        if(option.owner != msg.sender) throw;  
        if(option.expiry < now) throw;
        
        var supply = option.token.totalSupply();
        if(!option.sell_token.transfer(msg.sender,supply)) throw;
        option.token.destroy();
        delete option_info[id];
        
        closeEvent(id);
    }
}
