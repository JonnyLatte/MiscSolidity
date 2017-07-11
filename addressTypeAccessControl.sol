pragma solidity ^0.4.12;

// modifiers for limiting function caller to accounts or contracts
//
// see also: https://github.com/Giveth/minime/blob/master/contracts/MiniMeToken.sol#L502-L512

contract addressTypeAccessControl {

    modifier onlyContract {
        assert(msg.sender != tx.origin);
        _;
    }

    modifier onlyAccount {
        assert(msg.sender == tx.origin);
        _;
    }
}
