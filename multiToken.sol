
pragma solidity ^0.4.4;

import "github.com/JonnyLatte/MiscSolidity/erc20.sol"; 
import "github.com/JonnyLatte/MiscSolidity/SafeMath.sol";
import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";

contract MULTITOKEN {
    event Transfer(address indexed token, address indexed from, address indexed to, uint value);
    event Approval(address indexed token, address indexed owner, address indexed spender, uint value);
    function totalSupply(address token) constant returns (uint supply);
    function balanceOf(address token, address who ) constant returns (uint value);
    function allowance(address token, address owner, address spender) constant returns (uint _allowance);   
    function transfer(address token, address to, uint value) returns (bool ok);
    function transferFrom(address token, address from, address to, uint value) returns (bool ok);
    function approve(address token, address spender, uint value) returns (bool ok);
}

contract MultiTokenBase is MULTITOKEN, SafeMath {
    
    mapping( address => mapping(address => uint) ) _balances;
    mapping( address => mapping(address => mapping( address => uint )) ) _approvals;
    mapping( address => uint) _supply;

    function totalSupply(address token) constant returns (uint supply) {
        return _supply[token];
    }
    
    function balanceOf( address token, address who ) constant returns (uint value) {
        return _balances[token][who];
    }
    
    function transfer( address token, address to, uint value) returns (bool ok) {
        
        _balances[token][msg.sender] = safeSub(_balances[token][msg.sender],value);
        _balances[token][to]         = safeAdd(_balances[token][to]        ,value);
        Transfer(token, msg.sender, to, value );
        return true;
    }
    
    function transferFrom(address token, address from, address to, uint value) returns (bool ok) {
        // if you don't have approval, throw
        if( _approvals[token][from][msg.sender] < value ) throw;
        if(_balances[token][to] + value < _balances[token][to]) throw;

        // transfer and return true
        _approvals[token][from][msg.sender] = safeSub(_approvals[token][from][msg.sender],value);
        _balances[token][from]              = safeSub(_balances[token][from]             ,value);
        _balances[token][to]                = safeAdd(_balances[token][to]               ,value);
        Transfer(token, from, to, value );
        return true;
    }
    
    function approve(address token, address spender, uint value) returns (bool ok) {
        _approvals[token][msg.sender][spender] = value;
        Approval(token, msg.sender, spender, value );
        return true;
    }
    
    function allowance(address token, address owner, address spender) constant returns (uint _allowance) {
        return _approvals[token][owner][spender];
    }
    
}

contract multiGenTokenBase is MultiTokenBase 
{
   uint public last_token_id; 
   
   function getNewTokenAddress() internal returns(address) {
       last_token_id++;
       return address(last_token_id);
   }
}

contract multiSimpleToken is multiGenTokenBase {
    
    function createToken(uint supply) returns (address token) 
    {
        token = getNewTokenAddress();
        
        _balances[token][msg.sender] = supply;
        _supply[token] = supply;
    }
}

contract multiOwnedToken is multiGenTokenBase {
    
    mapping(address => address) public owner;

    function createToken(uint supply) returns (address token) {

        token = getNewTokenAddress();
        
        owner[token] = msg.sender;
        _balances[token][msg.sender] = supply;
        _supply[token] = supply;
    }
    
    function transferOwnership(address token, address newOwner) returns (bool ok) {
        
        if(owner[token] != msg.sender) throw;
        
        owner[token] = newOwner;
        
        return true;
    }
    
    function issue(address token, address account, uint value) returns (bool ok) {
        
        if(owner[token] != msg.sender) throw;

        _balances[token][account] = safeAdd(_balances[token][account], value);
        _supply[token]            = safeAdd(_supply[token],            value);
        
        Transfer(token, address(0), account, value);
        
        return true;
    }
    
    function burn(address token, address account, uint value) returns (bool ok) {
        
        if(owner[token] != msg.sender) throw;
        
        _balances[token][account] = safeSub(_balances[token][account], value);
        _supply[token]            = safeSub(_supply[token],            value);
        
        Transfer(token, account, address(0), value);
        
        return true;
    }
}

contract fundManager is MultiTokenBase {
    
    mapping (address => uint256) public funds; // integrity check
    
    event Deposit( address indexed _token, address indexed _from, address indexed _to  , uint256 _value);
    event Withdraw(address indexed _token, address indexed _from, address indexed _to  , uint256 _value);

    function deposit(address _token,address _to, uint256 _value ) 
    {
        if(!ERC20(_token).transferFrom(msg.sender,this,_value)) throw;          // external call 1
        uint256 balance = ERC20(_token).balanceOf(this);                        // external call 2
        uint256 value = safeSub(balance, funds[_token]);
        _balances[_token][ _to] = safeAdd(_balances[_token][ _to], value);
        funds[_token] = balance;
        Deposit(_token,msg.sender,_to, value);
    }

    function withdraw(address _token, address _to, uint256 _value)  {
        funds[_token] = safeSub(funds[_token], _value);
        _balances[_token][msg.sender] = safeSub(_balances[_token][msg.sender], _value);
        if(!ERC20(_token).transfer(_to,_value)) throw;                          // external call 3
        var fund_balance = ERC20(_token).balanceOf(this);                       // external call 4
        if(funds[_token] < fund_balance) 
        {
            // if after transfer contract funds are lower than expected
            // try and remove shortfall from user account (assume it was a fee built into the token) otherwise throw
            uint256 fee = safeSub(funds[_token], fund_balance);
            if(fee > _balances[_token][msg.sender]) throw;
            _balances[_token][msg.sender] = safeSub(_balances[_token][msg.sender], fee);
            funds[_token] = fund_balance;
        }
        Withdraw(_token,msg.sender,_to , _value);
    }
    
    function appTransfer(address _token, address owner,  address _to, uint256 _value) internal returns (bool ok) {
        _balances[_token][owner] = safeSub( _balances[_token][owner], _value);
        _balances[_token][_to]   = safeAdd( _balances[_token][_to]  , _value);
        Transfer(_token,msg.sender,_to,_value);
    } 
}

contract fundManagerEX is fundManager, multiOwnedToken {
    
}

contract multiTokenToERC20 is baseToken, SafeMath {
    
    MULTITOKEN public multi;
    address    public token;
    
    function multiTokenToERC20( MULTITOKEN _multi, address  _token) {
        multi = _multi;
        token = _token;
    }
    
    function deposit(uint value) returns (bool ok) {
        if(!multi.transferFrom(token,msg.sender,this,value)) throw;
        
        _balances[msg.sender] = safeAdd(_balances[msg.sender],value);
        _supply = safeAdd(_supply,value);
        
        return true;
    }
    
    function widthraw(uint value) returns (bool ok) {
        
        _balances[msg.sender] = safeSub(_balances[msg.sender],value);
        _supply = safeSub(_supply,value);
        
        if(!multi.transfer(token,msg.sender,value)) throw;
        
        return true;
    }
}
