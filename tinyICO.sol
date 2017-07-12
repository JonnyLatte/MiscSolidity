pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/ownedToken.sol"; 

contract tinyICO is owned {

    using SafeMath for uint;

    ownedToken public saleToken;

    uint public startTime;
    uint public deadline; 
    uint public crowdsaleCap;
    uint public fundsRaised;
    uint public decimalModifier;


    function tinyICO(
        uint epochStartTime,
        uint durationInMinutes,
        uint256 capOnCrowdsale,
        uint _decimalModifier) 
    {
        assert(_decimalModifier != 0)
        saleToken = new ownedToken();
        startTime = epochStartTime;
        deadline  = epochStartTime + (durationInMinutes * 1 minutes);
        decimalModifier = _decimalModifier;
        crowdsaleCap = capOnCrowdsale * 1 ether;
    }

    function() payable {

        assert(fundsRaised.safeAdd(msg.value) < crowdsaleCap);
        assert(now > startTime);
        assert(now < deadline);

        fundsRaised += msg.value;

        assert(saleToken.mint(msg.sender,msg.value.safeMul(decimalModifier)));
    }

    function widthraw() onlyOwner {
        assert(now > deadline);
        owner.transfer(this.balance);
    }

}
