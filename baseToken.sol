pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/erc20.sol"; 
import "github.com/JonnyLatte/MiscSolidity/SafeMath.sol";

contract baseToken is ERC20 {
    
    using SafeMath for uint;
    
    mapping( address => uint ) _balances;
    mapping( address => mapping( address => uint ) ) _approvals;
    uint _supply;

    function totalSupply() public constant returns (uint supply) {
        return _supply;
    }
    
    function balanceOf( address who ) public constant returns (uint value) {
        return _balances[who];
    }
    
    function transfer( address to, uint value) public returns (bool success) 
    {
        _balances[msg.sender] = _balances[msg.sender].safeSub(value); // will throw if insufficient funds
        _balances[to]         = _balances[to].safeAdd(value);         // will throw if overflow
        
        Transfer( msg.sender, to, value );
        return true;
    }
    
    function transferFrom( address from, address to, uint value) public returns (bool success) 
    {
        _approvals[from][msg.sender] = _approvals[from][msg.sender].safeSub(value); // will throw if insufficient approval
        _balances[from]              = _balances[from].safeSub(value);              // will throw if insufficient funds
        _balances[to]                = _balances[to].safeAdd(value);                // will throw if overflow
        
        Transfer( from, to, value );
        return true;
    }
    
    function approve(address spender, uint value) public returns (bool success) {
        _approvals[msg.sender][spender] = value;
        Approval( msg.sender, spender, value );
        
        return true;
    }
    
    function allowance(address owner, address spender) public constant returns (uint _allowance) {
        return _approvals[owner][spender];
    }
}
