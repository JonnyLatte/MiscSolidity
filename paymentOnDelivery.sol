pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/moneyBox.sol"; 

contract paymentOnDelivery is moneyBox {

    // make a transfer and then if successful pay the miner
    function tranferAndPayMiner(address _to, uint _value, bytes _data, uint minerPayment) onlyOwner {
         require(_to.call.value(_value)(_data));
         block.coinbase.transfer(minerPayment);
    }
}
