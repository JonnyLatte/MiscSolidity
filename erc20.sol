pragma solidity ^0.4.12;

contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
    function totalSupply() public constant returns (uint supply);
    function balanceOf( address who ) public constant returns (uint value);
    function allowance(address owner, address spender) public constant returns (uint _allowance);   
    function transfer( address to, uint value) public returns (bool success);
    function transferFrom( address from, address to, uint value) public  returns (bool success);
    function approve(address spender, uint value) public returns (bool success);
}
