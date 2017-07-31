// contract with owner and withdrawal and generic function call capability  

pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/owned.sol"; 
import "github.com/JonnyLatte/MiscSolidity/erc20.sol"; 

contract moneyBox is owned {

    // transfer just ether with no data / function calls
    function transferEther(address _to, uint _value) onlyOwner {
        _to.transfer(_value);
    }

    // generic transfer function can interact with contracts by supplying data
    function genericTransfer(address _to, uint _value, bytes _data) onlyOwner {
         require(_to.call.value(_value)(_data));
    }

    //transfer out tokens (can be done with the generic transfer function by supplying the function signature and parameters)
    function tokenTransfer(ERC20 _token, address _to, uint _value) onlyOwner {
         require(_token.transfer(_to,_value));
    }
}
