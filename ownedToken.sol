pragma solidity ^0.4.8;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";
import "github.com/JonnyLatte/MiscSolidity/owned.sol";

contract ownedToken is baseToken, owned  {
    
    function issue(uint256 value, address to) onlyOwner  returns (bool ok)
    {
        _balances[to] = safeAdd(_balances[to],value);
        _supply = safeAdd(_supply,value);
        return true;
    }
    
    function burn(uint256 value, address from) onlyOwner  returns (bool ok)
    {
        _balances[from] = safeSub(_balances[from],value);
        _supply = safeSub(_supply,value);
        return true;
    }
    
    function destroy() onlyOwner {
        suicide(msg.sender);
    }
 
    function () {
        throw;
    }
}
