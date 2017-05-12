// Mutex contract modified from
// https://solidity.readthedocs.io/en/develop/contracts.html#function-modifiers

contract Mutex {
    bool locked;
    modifier noReentrancy() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }
}
