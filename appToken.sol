pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";

contract appToken is baseToken {
    
    function issueTokens(address target, uint256 value) internal
    {
        _balances[target] = _balances[target].safeAdd(value);
        _supply = _supply.safeAdd(value);
        Transfer(0,target,value);
    }
    
    function burnTokens(address target, uint256 value) internal
    {
        _balances[target] = _balances[target].safeSub(value);
        _supply = _supply.safeSub(value);
        Transfer(target,0,value);
    }
}
