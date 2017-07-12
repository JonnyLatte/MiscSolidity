pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";
import "github.com/JonnyLatte/MiscSolidity/owned.sol";

contract ownedToken is baseToken, owned  {
    
    function mint(address to, uint256 value) onlyOwner  returns (bool ok)
    {
        _balances[to] = _balances[to].safeAdd(value);
        _supply = _supply.safeAdd(value);
        return true;
    }
    
    function burn(address from,uint256 value) onlyOwner  returns (bool ok)
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
