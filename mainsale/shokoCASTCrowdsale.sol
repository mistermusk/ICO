pragma solidity ^0.4.20;

import '../zeppelin/contracts/crowdsale/FinalizableCrowdsale.sol';
import './KYC.sol';
import './KYC2.sol';
import './pools/AdvisoryPool.sol';
import './pools/CommunityPool.sol';
import './pools/CompanyReserve.sol';
import './pools/PresalePool.sol';

contract shokoCASTCrowdsale is FinalizableCrowdsale {

    // Cap & price related values
    uint256 public constant HARD_CAP = 3981753*(10**11);
    uint256 public toBeRaised = 3981753*(10**11);
    uint256 public constant PRICE = 44560;
    uint256 public tokensSold;
    uint256 public constant maxTokens = 3981753500*(10**9);

    // Allocation constants
    uint constant ADVISORY_SHARE = 119452605*(10**9); //FIXED
    uint constant BOUNTY_SHARE = 39817535*(10**9); // FIXED
    uint constant COMMUNITY_SHARE = 955620840*(10**9); //FIXED
    uint constant COMPANY_SHARE = 796350840*(10**9); //FIXED
    uint constant PRESALE_SHARE = 1990876750*(10**9); // FIXED;

    // Address pointers
    address constant ADVISORS = 0x19b6C9E13E74eB777ff1A3Df9E6568b389E6B237; // TODO: change
    address constant BOUNTY = 0xe86af07B52CbD82BB17a9A36d720CF26C864e5C1; // TODO: change
    address constant COMMUNITY = 0xdC6D29604b8E69bb01039801A897A755B1Cf3e14; // TODO: change
    address constant COMPANY = 0xae361E3aA5fAd69AD4Ca197b6fD65FEF21dd1F6E; // TODO: change
    address constant PRESALE = 0x28F8a9f08A277F5AaB976634FAEC9F1bf5D72ED1; // TODO: change
    CrowdsaleRegister register;
    PrivateRegister register2;

    // Start & End related vars
    bool public ready;

    // Events
    event SaleWillStart(uint256 time);
    event SaleReady();
    event SaleEnds(uint256 tokensLeft);

    function shokoCASTCrowdsale(address _token, address _wallet, address _register, address _register2) public
    FinalizableCrowdsale()
    Crowdsale(_token, _wallet)
    {
        register = CrowdsaleRegister(_register);
        register2 = PrivateRegister(_register2);
    }
    

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool started = (startTime <= now); 
        bool nonZeroPurchase = msg.value != 0;
        bool capNotReached = (weiRaised < HARD_CAP);
        bool approved = register.approved(msg.sender);
        bool approved2 = register2.approved(msg.sender);
        return ready && started && !hasEnded && nonZeroPurchase && capNotReached && (approved || approved2);
    }

    /*
     * Buy in function to be called from the fallback function
     * @param beneficiary address
     */
    function buyTokens(address beneficiary) private {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // base discount
        uint256 discount = ((toBeRaised*10000)/HARD_CAP)*15;
                
        // calculate token amount to be created
        uint256 tokens;

        // update state
        weiRaised = weiRaised.add(weiAmount);
        toBeRaised = toBeRaised.sub(weiAmount);

        uint commission;
        uint extra;
        uint premium;

        if (register.approved(beneficiary)) {
            (commission, extra) = register.getBonuses(beneficiary);

            // If extra access granted then give additional %
            if (extra > 0) {
                discount += extra*10000;
            }
            tokens =  howMany(msg.value, discount);

            // If referral was involved, give some percent to the source
            if (commission > 0) {
                premium = tokens.mul(commission).div(100);
                token.mint(BOUNTY, premium);
            }

        } else {
            extra = register2.getBonuses(beneficiary);
            if (extra > 0) {
                discount = extra*10000;
                tokens =  howMany(msg.value, discount);
            }
        }

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        tokensSold += tokens + premium;
        forwardFunds();
        
        assert(token.totalSupply() <= maxTokens);
    }

    /*
     * Helper token emission functions
     * @param value uint256 of the wei amount that gets invested
     * @return uint256 of how many tokens can one get
     */
    function howMany(uint256 value, uint256 discount) public view returns (uint256){
        uint256 actualPrice = PRICE * (1000000 - discount) / 1000000;
        return value / actualPrice;
    }

    /*
     * Function to do preallocations - MANDATORY to continue
     * @dev It's separated so it doesn't have to run in constructor
     */
    function initialize() public onlyOwner {
        require(!ready);

        // Pre-allocation to pools
        token.mint(ADVISORS,ADVISORY_SHARE);
        token.mint(BOUNTY,BOUNTY_SHARE);
        token.mint(COMMUNITY,COMMUNITY_SHARE);
        token.mint(COMPANY,COMPANY_SHARE);
        token.mint(PRESALE,PRESALE_SHARE);

        tokensSold = PRESALE_SHARE;
        
        ready = true; 
        SaleReady(); 
    }

    /*
     * Function to do set or adjust the startTime - NOT MANDATORY but good for future start
     */
    function changeStart(uint256 _time) public onlyOwner {
        startTime = _time;
        SaleWillStart(_time);
    }

    /*
     * Function end or pause the sale
     * @dev It's MANDATORY to finalize()
     */
    function endSale(bool end) public onlyOwner {
        require(startTime <= now);
        uint256 tokensLeft = maxTokens - token.totalSupply();
        if (tokensLeft > 0) {
            token.mint(wallet, tokensLeft);
        }
        hasEnded = end;
        SaleEnds(tokensLeft);
    }
    
    /*
     * Adjust finalization to transfer token ownership to the fund holding address for further use
     */
    function finalization() internal {
        token.finishMinting(); 
        token.transferOwnership(wallet);
    }

    /*
     * Clean up function to get the contract selfdestructed - OPTIONAL
     */
    function cleanUp() public onlyOwner {
        require(isFinalized);
        selfdestruct(owner);
    }

}



