pragma solidity ^0.4.8;

// strToInt take a string say "123" and returns an integer and the index of the next character after a seperator (for example "," ) is found
//
// strToInt( string str, // input string
//        uint index, // index of the first character of the integer to parse 
//        uint base) // 10 for base 10, 16 for hexidecimal encoding 
//
// strToInt("123,456",0,10) returns (123,4) parsing the first decimal integer in the string
// strToInt("123,456",4,10) returns (456,8) parsing the second decimal integer in the string
// strToInt("a,10",0,16) returns (10,2) parsing the first hexidecimal integer in the string
// strToInt("a,10",2,16) returns (16,5) parsing the second hexidecimal integer in the string
//
// example parsing a decimal followed by an address (hex encoded no 0x)
//
//    function parse2int(string str) constant returns (uint,address) {
//        var (s1,i) = strToInt(str,0,10);
//        var (s2, ) = strToInt(str,i,16);
//        return (s1,(address)(s2));
//    }
    
contract parseInt {
     
    function strToInt( string str, uint index, uint base) constant returns (uint,uint) {
        
        uint sum = 0;
        uint i   = 0;
        
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
