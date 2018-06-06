const web3 = require('web3')


// usage:
// 
// node rootProof.js >> proofs.txt
//
// outputs a file containing the root hash and merkle proofs compatible with rootToken contract:
// https://github.com/JonnyLatte/MiscSolidity/blob/master/rootToken.sol

let filename = "addresses.txt"; // file to parse comma seperated items each line
let addressIndex = 1; // index of the ethereum address item in  a line
let balanceIndex = 2; // index of the balance item

// hash address
//console.log(web3.utils.soliditySha3({t: 'address', v: '0xe853c56864a2ebe4576a807d26fdc4a0ada51919'}))
//console.log("0x9905b2d398f416d8e5f55d589dc56e175542e780031de84bb94cb4e82c30c764")

//hash address + address
//console.log(web3.utils.soliditySha3({t: 'address', v: '0xe853c56864a2ebe4576a807d26fdc4a0ada51919'},{t: 'address', v: '0xe853c56864a2ebe4576a807d26fdc4a0ada51919'}))
//console.log("0x17a0de393af08ac725966b7368169e0abf8039012f0069d0bfc6cb4ae7825514")


//hash address + uint
//console.log(web3.utils.soliditySha3({t: 'address', v: arr[0][1]}))
//console.log(web3.utils.soliditySha3({t: 'address', v: arr[0][1]},{t: 'uint', v: arr[0][2]}))


// Sample Data: https://gist.github.com/JonnyLatte/327c601479d004c86d4d81db622fdb33
// Sample proofs: https://gist.github.com/JonnyLatte/e183154d2f9b06a63f1bc06845a95ad4


function hashAddress(address) {
    return web3.utils.soliditySha3({t: 'address', v: address})
};

function padZeros(x,len) {
	return Array(len-x.length+1).join("0") + x;
}

function hashAddressValue(address,value,id) 
{
    try {
        return web3.utils.soliditySha3({t: 'address', v: address},{t: 'uint', v: value});
    }
    catch (e) {
        console.log("hashAddressValue Error: " + e +" " + address + " "+value+" " +id);
    }
};

function hash2hash(a,b) {
    try {
        v = a + b.replace('0x','')
        //console.log(v);
        return web3.utils.soliditySha3(v);
    }
    catch (e) {
        console.log("hash2hash Error: " + e +" " + a + " "+b);

    }
};


class node 
{
	constructor(hash,parent,sibling) {
		this.hash = hash;
		this.parent = parent || null;
		this.sibling = sibling || null;
	}
}
class addressValuePair extends node 
{
	constructor(address,balance) {
		super(hashAddressValue(address,balance));		
		this.address = address;
		this.balance = balance;		
	}
}

class preImage extends node 
{
	constructor(a,b) 
	{	
		if(a.hash > b.hash)	{					
			super(hash2hash(a.hash,b.hash));			
		} else {
			super(hash2hash(b.hash,a.hash));			
		}
			
		a.parent = this;
		b.parent = this;		
		a.sibling = b.hash;
		b.sibling = a.hash;
	}
}
class treeBuilder {
	
	constructor() {	
		this.nodes = [];
		this.leaves = [];		
		this.processed = [];
	}
	
	addRecord(address,balance,id) {	
        if(typeof address == "undefined" || typeof balance == "undefined") return null;	
		let obj = new addressValuePair(address,balance,id);
		this.leaves.push( obj );
		return obj;
	}
	
	reduce() {
		this.nodes = this.leaves.slice(0);
		let c = null;
		while(this.nodes. length > 1) {		
			this.nodes.push(c = new preImage(this.nodes.shift(),this.nodes.shift()) );			
		}	
		return c;
	}
	
	getProof(item) {
		let hashes = [];
				
		while(item.parent != null)
		{
			hashes.push(item.sibling);		
			item = item.parent;
		}
		
		return hashes;
	}
	
}

var fs = require('fs');
fs.readFile(filename, 'utf8', function(err, data) {
  if (err) throw err;
  //console.log('OK: ' + filename);

    let arr = data.split('\n');
    let duplicates = 0;
    let tree = new treeBuilder();

    for(let i = 0; i < arr.length; i++ ) {
        arr[i] = arr[i].split(',');

        // aggrigate duplicate addresses into one balance
        for(let j = 0; j < i; j++ ) {
            if(arr[i][addressIndex] == arr[j][addressIndex]) {
               arr[i][balanceIndex] = new web3.utils.BN(arr[i][balanceIndex]).add(new web3.utils.BN(arr[j][balanceIndex])).toString();
               arr[j][balanceIndex] = 0;
               duplicates++; 
            }
        }
        //tree.addRecord(arr[i][1],arr[i][2],i);
        //if(i>=1) break;
    } 

    for(let i = 0; i < arr.length; i++ ) {
        if(arr[i][balanceIndex] != 0) {
            tree.addRecord(arr[i][addressIndex],arr[i][balanceIndex],i);
        }
    } 

    console.log("Root Hash: "+tree.reduce().hash)
    console.log("Records: "+tree.leaves.length + " Duplicates: " +duplicates)
    console.log("-------------------------");

    for(let i = 0; i< tree.leaves.length; i++) {

        let proof = tree.getProof(tree.leaves[i]);
        
        console.log(JSON.stringify(proof)+","+JSON.stringify(tree.leaves[i].address) + "," + tree.leaves[i].balance );
    }
        
});

