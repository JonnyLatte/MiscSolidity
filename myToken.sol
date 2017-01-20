pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";

contract MyToken is baseToken {
    
    string public name;
    string public symbol;
    string public version;
    uint8 public decimals;

    function MyToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        string versionOfTheCode
        ) {
        _balances[msg.sender] = initialSupply;              // Give the creator all initial tokens
        _supply = initialSupply;                            // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
        version = versionOfTheCode;
    }
    
    function () {
        throw;
    }
}
