pragma solidity ^0.4.12;

import "github.com/JonnyLatte/MiscSolidity/SafeMath.sol";

//-----------------------------------------------------------------------------------------------------
// 
//  Mica, ERC20 token OTC exchange.
//
//  JonnyLatte (c) 2017 The MIT License.
//
//-----------------------------------------------------------------------------------------------------


// ERC20 defines the standard token interface 
// any token implementing transfer and transferFrom will be usable with this exchange

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function totalSupply() constant returns (uint totalSupply);
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
    function approve(address _spender, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract MicaTypes {
    
    struct OFFER {
        address owner;  // owner of the offer
        ERC20 currency; // "currency" refers to the token used to buy with
        ERC20 asset;    // "asset" refers to the token that is on offer
        uint units;     // asset is sold in multiples of "units"
        uint price;     // amount of currency needed to buy a lot of units
        uint balance;   // amount of asset belonging to this offfer
    }
    
    bool constant NEXT = true; 
    bool constant PREV = false;      
}

contract Mica is MicaTypes
{
    using SafeMath for uint;
    
    // track UpdateEvent for any change in the status of an offer
    event  UpdateEvent(uint offer_index, address indexed currency, address indexed asset);
    
    // track FillEvent for just fecthing trades
    event  FillEvent(
        address indexed currency_token, 
        address indexed asset_token, 
        uint currency_value,  
        uint asset_value,
        address seller,
        address buyer);

    // offers stores all offer data in one big int array
    // the index to each offer never changes
    // last_offer_index will be the index of the next offer created 
    // (incremented by one each time)
    // offer data is retrieved with getOfferInfo()
    
    uint public last_offer_index;
    mapping(uint => OFFER) offers; 
    
    // firstOffer contains the index to the first offer of a given currency pair
    
    mapping(address => mapping(address => uint)) public firstOffer;

    // link stores a linked list, data values are key values so must be unique
    // in this case the key is the offer index 
    // each link points to the next offer in the same currency pair
    
    mapping(uint => mapping(bool => uint)) public link;
    
    // user_offers maps to offers for a given address. Offer index values are not removed from this mapping
    // last_user_offer_index is the number of offers created by a given address and the position in the mapping of the last one
    
    mapping(address => uint) public last_user_offer_index;
    mapping(address => mapping(uint => uint)) public user_offers;
    
    // increment and get offer index
    
    function nextOfferIndex() internal returns (uint) {
        return ++last_offer_index;
    }
    
    //increment storage position for user offer index values
    
    function nextUserOfferIndex(address user) internal returns (uint) {
        return ++last_user_offer_index[user];
    }
    
    // create an offer
    // removing balance amount of asset (the token being sold) from the sender
    // contracts wanting to callMake offer and know the resulting offer index can get the value of last_offer_index
    // after the call is made and before any subsiquent offer creation
    
    function makeOffer(
        ERC20 currency,
        ERC20 asset,
        uint units,
        uint price,
        uint balance
        ) returns (bool ok)
    {       
        if(units == 0) throw;
        if(price == 0) throw;
        if(currency == address(0)) throw;
        if(asset == currency) throw;
        if(balance < units) throw;

        if(!asset.transferFrom(msg.sender,this,balance)) throw;

        OFFER memory offer;
        
        offer.owner = msg.sender;
        offer.currency = currency;
        offer.asset = asset;
        offer.units = units;
        offer.balance = balance;
        offer.price = price;
        
        uint offerIndex = nextOfferIndex();
        
        offers[offerIndex] = offer;
        
        // create list for specific currency pair
        link[offerIndex][NEXT] = firstOffer[currency][asset];
        link[firstOffer[currency][asset]][PREV] = offerIndex;
        firstOffer[currency][asset] = offerIndex;
        
        UpdateEvent(offerIndex, currency, asset);
        
        // record offer for indexing by user
        user_offers[msg.sender][nextUserOfferIndex(msg.sender)] = offerIndex;

        return true;
    }
    
    // taker fills offer, removing it if filled
    
    function buy(uint offer_index, uint asset_amount_to_buy) returns (bool ok) 
    {
        OFFER offer = offers[offer_index];
        
        if(offer.units == 0) return; // expired offer has zero units
     
        uint unit_lots_to_buy  = asset_amount_to_buy / offer.units;
        uint unit_lots_on_offer = offer.balance / offer.units;
        
        if(unit_lots_to_buy > unit_lots_on_offer)  {
           unit_lots_to_buy  = unit_lots_on_offer;
        }
        
        if(unit_lots_to_buy == 0) return false;
        
        uint currency_value = unit_lots_to_buy.safeMul(offer.price);
        uint asset_value    = unit_lots_to_buy.safeMul(offer.units);
        
        if(currency_value < unit_lots_to_buy) throw; //overflow test
        if(asset_value < unit_lots_to_buy) throw; //overflow test
        
        offers[offer_index].balance = offers[offer_index].balance.safeSub(asset_value);
       
        if(!offer.currency.transferFrom(msg.sender,offer.owner,currency_value)) throw; 
        if(!offer.asset.transfer(msg.sender,asset_value)) throw;
        
        if(offer.balance < offer.units) {
            internalCancelOffer(offer_index);
        }

        UpdateEvent(offer_index, offer.currency, offer.asset);                  
        FillEvent(offer.currency, offer.asset,currency_value,asset_value,offer.owner,msg.sender);      

        return true;
    }

    // remove offer index from list of offers associated with each currency pair

    function internalUnlink(uint offer_index, address currency, address asset) internal {
        link[link[offer_index][PREV]][NEXT] = link[offer_index][NEXT];
        link[link[offer_index][NEXT]][PREV] = link[offer_index][PREV];
        if( firstOffer[currency][asset] == offer_index) {
            firstOffer[currency][asset] = link[offer_index][NEXT];
        }
    }
    
    // internalCancelOffer() 
    // called by cancelOffer to cancel an offer 
    // and buy() when an order has less funds than can be sold (dust is returned to owner)

    function internalCancelOffer(uint offer_index) internal 
    {
        OFFER offer = offers[ offer_index];
        
        internalUnlink( offer_index,offer.currency,offer.asset);
        
        UpdateEvent(offer_index, offer.currency, offer.asset);
        
        if(offer.balance > 0) {
            if(!offer.asset.transfer(offer.owner,offer.balance)) throw;
        }
        
        delete offers[offer_index];
    }
    
    // Cancel an offer returning funds to owner
    
    function cancelOffer(uint offer_index) returns (bool ok)
    {
        if(msg.sender == offers[offer_index].owner) {
            internalCancelOffer(offer_index);
            UpdateEvent(offer_index, offers[offer_index].currency, offers[offer_index].asset);
            return true;
        }
        return false;
    }
 
    // Add additional funds to offer
    
    function fundOffer(uint offer_index, uint additional_balance) returns (bool ok)
    {
        if(msg.sender == offers[offer_index].owner) 
        {
            if(!offers[offer_index].asset.transferFrom(msg.sender,this,additional_balance)) throw;
            
            offers[offer_index].balance = offers[offer_index].balance + additional_balance;
            
            if(offers[offer_index].balance < additional_balance) throw; // overflow check
            
            UpdateEvent(offer_index, offers[offer_index].currency, offers[offer_index].asset);
            return true;
        }
        return false;
    }

    // Returns information about an offer offer_index
    // next will be an order index of the same pair 

    function getOfferInfo(uint offer_index) constant returns (
        uint index,
        address owner,
        ERC20 currency,
        ERC20 asset,
        uint units,
        uint price,
        uint balance,
        uint next
        ) 
    {
         index = offer_index;
        
         OFFER offer = offers[offer_index]; 
        
         owner    = offer.owner;
         asset    = offer.asset;
         currency = offer.currency;
         units    = offer.units;
         price    = offer.price;
         balance  = offer.balance;
         
         next     = link[offer_index][NEXT];
    }   
}


// MicaHelper: pull specific data from Mica contract
// This could be included in Mica itself but is seperate to keep the Mica contract simple

contract MicaHelper is MicaTypes
{
    using SafeMath for uint;
    
    function countOffersFrom(Mica mica, uint offer_index) constant returns (uint) {
        if(offer_index == 0) return 0;
        return 1 + countOffersFrom(mica,mica.link(offer_index,NEXT));
    }
    
    function countOffers(Mica mica, address currency, address asset) constant returns (uint count) {
        count = countOffersFrom(mica, mica.firstOffer(currency,asset));
    }
    
    function getMarketOffer(Mica mica, address _currency, address _asset, uint _pos) constant returns (
        uint index,
        address owner,
        ERC20 currency,
        ERC20 asset,
        uint units,
        uint price,
        uint balance,
        uint next
        ) 
    {
        uint offer_index = mica.firstOffer(_currency,_asset);
        
        while(_pos > 0 && offer_index != 0) {
            offer_index = mica.link(offer_index,NEXT);
           _pos--;
        }
        
        return mica.getOfferInfo(offer_index);
    }
    
    function getUserOffer(Mica mica, address _user, uint _pos) constant returns (
        uint index,
        address owner,
        ERC20 currency,
        ERC20 asset,
        uint units,
        uint price,
        uint balance,
        uint next
        ) 
    {
        return mica.getOfferInfo(mica.user_offers(_user,_pos));
    }
    
    
    
    function bestOffer(Mica mica, address _currency, address _asset, uint minBalance) constant returns (uint best) {
        uint offer_index = mica.firstOffer(_currency,_asset);
        best = offer_index;
        
        uint best_units;
        uint best_price;
        uint best_balance;
        
        uint current_units;
        uint current_price;
        
        uint current_balance;
        
        (,,,,best_units,best_price,best_balance,) = mica.getOfferInfo(offer_index);
         
        offer_index = mica.link(offer_index,NEXT);
        
        while(offer_index != 0) {
            
            (,,,,current_units,current_price,current_balance,) = mica.getOfferInfo(offer_index);
            
            if(current_price * best_units < best_units.safeMul(current_price) && current_balance  >= minBalance) {
                best = offer_index;
                (best_units,best_price,best_balance) = (current_units,current_price,current_balance);
            }
            
            offer_index = mica.link(offer_index,NEXT);
        }
        
        if(best_balance < minBalance) best = 0;
        
        return best;
    } 
}

