pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/owned.sol";
import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";

//testing token enables anyone to issue it or zero a balance

contract testToken is baseToken  {
    
    function issue(uint256 value)  returns (bool ok)
    {
        if (_balances[msg.sender] + value < _balances[msg.sender]) throw; // Check for overflows
        _balances[msg.sender] += value;
        _supply += value;
        Transfer( 0x0,msg.sender, value );
        return true;
    }
    
    function burn(uint256 value)  returns (bool ok)
    {
        if (_balances[msg.sender] < value) throw;
        _balances[msg.sender] -= value;
        _supply -= value;
        Transfer( msg.sender, 0x0, value );
        return true;
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
