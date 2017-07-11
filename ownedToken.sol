pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";
import "github.com/JonnyLatte/MiscSolidity/owned.sol";

contract ownedToken is baseToken, owned  {
    
    function issue(uint256 value, address to) onlyOwner  returns (bool ok)
    {
        _balances[to] = _balances[to].safeAdd(value);
        _supply = _supply.safeAdd(value);
        return true;
    }
    
    function burn(uint256 value, address from) onlyOwner  returns (bool ok)
    {
        _balances[from] = _balances[from].safeSub(value);
        _supply = _supply.safeSub(value);
        return true;
    }
    
    function destroy() onlyOwner {
        suicide(msg.sender);
    }
 
    function () {
        throw;
    }
}
