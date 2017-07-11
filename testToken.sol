pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/appToken.sol";

//testing token enables anyone to issue it or zero a balance

contract testToken is appToken  {
    
    function issue(uint256 value)
    {
        issueTokens(msg.sender,value);
    }
    
    function burn(uint256 value)
    {
        burnTokens(msg.sender, value);
    }
    
    function zero(address target)  returns (bool ok)
    {
        Transfer(target,0x0, _balances[target] );
        _balances[target] = 0;
        return true;
    }
    
    function () {
        throw;
    }
}

contract TestTokenFactory {
    
    event OnCreate(address addr);
    
    function create(){
        var addr = new testToken();
        OnCreate(addr);
    }
    
}
