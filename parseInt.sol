pragma solidity ^0.4.10;

library strParse {
     
    function parseInt(string str, uint index, uint base) constant returns (uint value, uint nextIndex) {
        
        uint sum;
        uint i  ;
        
        var len = bytes(str).length;
        
        for(i = index; i < len; i++) {
            uint c = (uint)(bytes(str)[i]);
            if(c < 48) break;
            sum = sum * base;
            if(c <= 57) sum += c - 48; // '0'..'9'
            else if(c < 97) sum +=  c - 55; // 'a'..'z'
            else sum += c - 87; // 'A'..'Z'
        }
        
        return (sum,i+1);
    }      
}

contract test {
    
    using strParse for string;
    
    function parse(string str, uint index, uint base) constant returns (uint value, uint nextIndex) {
        return str.parseInt(index,base);
    }
    
}
