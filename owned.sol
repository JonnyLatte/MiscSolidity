pragma solidity ^0.4.4;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract ownedWithAproval
{
    address public approvedOwner;
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) 
        onlyOwner 
        returns (bool ok)
    {
        owner = newOwner;
        approvedOwner = newOwner;
    }
    
    function approve(address newPotentialOwner) {
        approvedOwner = newPotentialOwner;
    }
    
    function claimOwnership() returns (bool ok) {
        if(msg.sender != approvedOwner) throw;
        owner = approvedOwner;
        return true;
    }
}
