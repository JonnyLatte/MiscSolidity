pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";

contract appToken is baseToken {
    
    function issueTokens(address target, uint256 value) internal
    {
        _balances[target] = safeAdd(_balances[target], value);
        _supply = safeAdd(_supply,value);
        Transfer(0,target,value);
    }
    
    function burnTokens(address target, uint256 value) internal
    {
        _balances[target] = safeSub(_balances[target], value);
        _supply = safeSub(_supply,value);
        Transfer(target,0,value);
    }
}
