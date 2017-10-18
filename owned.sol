pragma solidity ^0.4.12;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract ownedWithAproval
{
    address public approvedOwner;
    address public owner;

    function ownedWithAproval() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public
        onlyOwner 
        returns (bool ok)
    {
        owner = newOwner;
        approvedOwner = newOwner;
        return true;
    }
    
    function approve(address newPotentialOwner)  public
    onlyOwner 
    {
        approvedOwner = newPotentialOwner;
    }
    
    function claimOwnership()  public returns (bool ok) {
        require(msg.sender == approvedOwner);
        owner = approvedOwner;
        return true;
    }
}
