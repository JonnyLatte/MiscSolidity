pragma solidity ^0.4.10;

This is factory for generating DELEGATECALL forwarders. 

This project is the result of the following reddit thread:

https://www.reddit.com/r/ethereum/comments/6c1jui/delegatecall_forwarders_how_to_save_5098_on/

As well as the following:

https://blog.aragon.one/advanced-solidity-code-deployment-techniques-dc032665f434
https://www.reddit.com/r/ethereum/comments/6ic49q/any_assembly_programmers_willing_to_write_a/

An instance of forwardFactory can be found at 0xba9ef985D5dA61959B88577d2a392C11c8445A7f on the kovan network

forwardFactory abi: [ { "constant": false, "inputs": [ { "name": "addr", "type": "address" } ], "name": "deployForwarder", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "type": "function" }, { "anonymous": false, "inputs": [ { "indexed": false, "name": "", "type": "address" } ], "name": "codeDeployed", "type": "event" } ]

*/

contract forwardFactory {
    
    bytes fwdrCode = hex"602e600c600039602e6000f3366000600037611000600036600073f00df00df00df00df00df00df00df00df00df00d5af41558576110006000f3";
    
    function deployCode(bytes _code) internal returns (address deployedAddress)  {
        assembly {
          deployedAddress := create(0, add(_code, 0x20), mload(_code))
          jumpi(invalidJumpLabel, iszero(extcodesize(deployedAddress))) // jumps if no code at addresses
        }
        _code;
        codeDeployed(deployedAddress);
    } 
  

    function deployForwarder(address addr) returns(address) {
       
       for (uint i = 0; i < 20; i++) {
            fwdrCode[46-i] = byte(uint8(uint(addr) >> (8*i)));
       }
       
       return deployCode(fwdrCode);   
    }
    
    event codeDeployed(address);
}

contract fixedForwardFactory {
    
    bytes fwdrCode = hex"602e600c600039602e6000f3366000600037611000600036600073f00df00df00df00df00df00df00df00df00df00d5af41558576110006000f3";
    
    function deployCode(bytes _code) internal returns (address deployedAddress)  {
        assembly {
          deployedAddress := create(0, add(_code, 0x20), mload(_code))
          jumpi(invalidJumpLabel, iszero(extcodesize(deployedAddress))) // jumps if no code at addresses
        }
        _code;
        codeDeployed(deployedAddress);
    } 
  

    function fixedForwardFactory(address addr)  {
       for (uint i = 0; i < 20; i++) {
            fwdrCode[46-i] = byte(uint8(uint(addr) >> (8*i)));
       }
    }
    
    function deployForwarder() returns(address) {
       return deployCode(fwdrCode);   
    }
    
    event codeDeployed(address);
}
