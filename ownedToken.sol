pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";
import "github.com/JonnyLatte/MiscSolidity/owned.sol";

contract ownedToken is baseToken, owned  {
    
    function issue(uint256 value, address to) onlyOwner  returns (bool ok)
    {
        if (_balances[to] + value < _balances[to]) throw; // Check for overflows
        _balances[to] += value;
        _supply += value;
        return true;
    }
    
    function burn(uint256 value, address from) onlyOwner  returns (bool ok)
    {
        if (_balances[from] < value) throw;
        _balances[from] -= value;
        _supply -= value;
        return true;
    }
    
    function destroy() onlyOwner {
        suicide(msg.sender);
    }
 
    function () {
        throw;
    }
}
