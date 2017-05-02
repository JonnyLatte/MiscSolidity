pragma solidity ^0.4.8;

import "github.com/JonnyLatte/MiscSolidity/erc20.sol"; 
import "github.com/JonnyLatte/MiscSolidity/SafeMath.sol";

contract baseToken is ERC20, SafeMath {
    
    mapping( address => uint ) _balances;
    mapping( address => mapping( address => uint ) ) _approvals;
    uint _supply;

    function totalSupply() constant returns (uint supply) {
        return _supply;
    }
    
    function balanceOf( address who ) constant returns (uint value) {
        return _balances[who];
    }
    
    function transfer( address to, uint value) returns (bool ok) 
    {
        _balances[msg.sender] = safeSub(_balances[msg.sender],value); // will throw if insufficient funds
        _balances[to]         = safeAdd(_balances[to], value);        // will throw if overflow
        
        Transfer( msg.sender, to, value );
        return true;
    }
    
    function transferFrom( address from, address to, uint value) returns (bool ok) 
    {
        _approvals[from][msg.sender] = safeSub(_approvals[from][msg.sender], value); // will throw if insufficient approval
        _balances[from]              = safeSub(_balances[from], value);              // will throw if insufficient funds
        _balances[to]                = safeAdd(_balances[to], value);                // will throw if overflow
        
        Transfer( from, to, value );
        return true;
    }
    
    function approve(address spender, uint value) returns (bool ok) {
        _approvals[msg.sender][spender] = value;
        Approval( msg.sender, spender, value );
        
        return true;
    }
    
    function allowance(address owner, address spender) constant returns (uint _allowance) {
        return _approvals[owner][spender];
    }
}
