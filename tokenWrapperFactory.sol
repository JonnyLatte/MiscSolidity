pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/baseToken.sol";
import "github.com/JonnyLatte/MiscSolidity/owned.sol";

// Interface of a token contract that has transfer but not necessarily balanceOf(), transferFrom() and approve()
contract UncompliantToken 
{
     function transfer(address to, uint value) public returns (bool success);
}

// A deposit contract that 
contract DepositContract is owned {
    
    function ownerTransfer(UncompliantToken token, address target, uint amount) public onlyOwner returns (bool) {
        return token.transfer(target,amount);
    }
}

// manages all token deposit contracts so that only one deposit contract 
// is needed per user no matter how many tokens are wrapped
contract tokenWrapperFactory is owned {
    
    mapping(address => address) public depositContracts; // user => deposit address
    mapping(address => address) public wrapperContracts; // uncomplient token => erc20 wrapper
    
    modifier onlyTokenWrapper(address token) {
        require(msg.sender == wrapperContracts[token]);
        _;
    }
    
    function initDepositContract(address sender) public returns (address) {
        
        if(depositContracts[sender] == 0x0) {
            depositContracts[sender] = new DepositContract();
        }
        
        return depositContracts[sender];        
    }
    
    function initWrapper(address token) public returns (address) {
        if(wrapperContracts[token] == 0x0) {
            wrapperContracts[token] = new tokenWrapper(token);
        }
        
        return wrapperContracts[token];       
    }
    
    function wrapperCallsProcessDeposit(UncompliantToken token, address sender, uint amount) public onlyTokenWrapper(token) returns (bool) 
    {
        require(DepositContract(depositContracts[sender]).ownerTransfer(token,(address)(this),amount)); // moves funds from deposit contract to this contract
        return true;
    }
    
    function wrapperCallsProcessWithdraw(UncompliantToken token, address sender, uint amount) public onlyTokenWrapper(token) returns (bool) 
    {
        require(UncompliantToken(token).transfer(sender,amount)); // moves funds from deposit contract to this contract
        return true;
    }
    
            
    function custodianClaimsTrappedTokens(address wrapperToken, address token, uint amount) public onlyOwner returns (bool) 
    {
        return tokenWrapper(wrapperContracts[wrapperToken]).ownerTransfer(UncompliantToken(token),owner,amount);
    }
}

// individual ERC20 token that wraps a non ERC20 token.
contract tokenWrapper is owned, baseToken {
    
    UncompliantToken token;

    function tokenWrapper(address _token) public {
        token = UncompliantToken(_token);
    }
    
    function getDepositAddress(address user) public constant returns (address) {
        return tokenWrapperFactory(owner).depositContracts(user);
    }
    
    function initDepositAddress(address user) public returns (address) {
        return tokenWrapperFactory(owner).initDepositContract(user);
    }
    
    function processDeposit(uint amount) public returns (bool ok) {
        
        require(tokenWrapperFactory(owner).wrapperCallsProcessDeposit(token,msg.sender,amount));
        
        _balances[msg.sender] = _balances[msg.sender].safeAdd(amount);
        _supply = _supply.safeAdd(amount);
        return true;
    }
    
    function processDepositAll() public returns (bool ok) {
        return processDeposit(ERC20(token).balanceOf(msg.sender));
    }
    
    function withdraw(uint amount) public returns (bool ok) {
    
        _balances[msg.sender] = _balances[msg.sender].safeSub(amount);
        _supply = _supply.safeSub(amount);
        
        require(tokenWrapperFactory(owner).wrapperCallsProcessWithdraw(token,msg.sender,amount));
        
        return true; 
    }   
    
    function withdrawAll() public returns (bool ok) {
        return withdraw(_balances[msg.sender]);
    }
    
    function ownerTransfer(UncompliantToken badToken, address target, uint amount) public onlyOwner returns (bool) {
        return badToken.transfer(target,amount);
    }
}
