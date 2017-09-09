pragma solidity ^0.4.12;

// untested multisig contract

contract msig {

    uint public nonce;
    uint public m;
    mapping(address => bool) public allowed;

    function msig(address[] signers, uint _m) {
        m = _m;
        require(signers.length >= m);
        for(uint i = 0; i < signers.length; i++) {
            allowed[signers[i]] = true;
        }
    }
    
    function validateSignatures(bytes32 hash, address[] signers, bytes32[] r, bytes32[] s, uint8[] v) internal 
    {
        require(signers.length == m);
        require(r.length == m);
        require(s.length == m);
        require(v.length == m);
        
        for(uint i = 0; i < m; i++) {
            // signer must be allowed
            require(allowed[signers[j]]);
            // signer must be unique
            for(uint j = i+1; j < m; j++) {
                require(signers[i] != signers[j]);
            }
            // signer must provide valid signature
            require(signers[i] == ecrecover(hash,v[i],r[i],s[i]));
        }
        
        nonce++;      
    }

    function transfer(address to, uint value, bytes data, address[] signers, bytes32[] r, bytes32[] s, uint8[] v) {
        
        bytes32 hash = sha3(this,nonce,to,value,data);

        validateSignatures(hash,signers,r,s,v);
        
        require(to.call.value(value)(data));
    }
    
    function changeAddress(address from, address to, address[] signers, bytes32[] r, bytes32[] s, uint8[] v) 
    {
        bytes32 hash = sha3(this,nonce,from,to);
        
        validateSignatures(hash,signers,r,s,v);
        
        allowed[from] = false;
        allowed[to]   = true;
    }
    
    
}
