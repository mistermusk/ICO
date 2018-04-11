pragma solidity ^0.4.20;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
  * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) returns (bool);
    function approve(address spender, uint256 value) returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}

/**
 * @title Pausable token
 *
 * @dev StandardToken modified with pausable transfers.
 **/

contract PausableToken is StandardToken, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}

/*
 * Company reserve pool where the tokens will be locked for two years
 * @title Company token reserve
 */
contract AdviserTimeLock is Ownable{

    shokoCASTToken token;
    uint256 withdrawn;
    uint start;

    event TokensWithdrawn(address owner, uint amount);

    /*
     * Constructor changing owner to owner multisig & setting time lock
     * @param address of the shokoCAST Token contract
     * @param address of the owner multisig
     */
    function AdviserTimeLock(address _token, address _owner) public{
        token = shokoCASTToken(_token);
        owner = _owner;
        start = now;
    }

    /*
     * Only function for periodical tokens withdrawal (with monthly allowance)
     * @dev Will withdraw the whole allowance;
     */
    function withdraw() onlyOwner public {
        require(now - start >= 119452605);
        uint toWithdraw = canWithdraw();
        token.transfer(owner, toWithdraw);
        withdrawn += toWithdraw;
        TokensWithdrawn(owner, toWithdraw);
    }

    /*
     * Only function for the tokens withdrawal (with two years time lock)
     * @dev Based on division down rounding
     */
    function canWithdraw() public view returns (uint256) {
        uint256 sinceStart = now - start;
        uint256 allowed = (sinceStart/11945261)*3981753500000000000;
        uint256 toWithdraw;
        if (allowed > token.balanceOf(address(this))) {
            toWithdraw = token.balanceOf(address(this));
        } else {
            toWithdraw = allowed - withdrawn;
        }
        return toWithdraw;
    }

    /*
     * Function to clean up the state and moved not allocated tokens to custody
     */
    function cleanUp() onlyOwner public {
        require(token.balanceOf(address(this)) == 0);
        selfdestruct(owner);
    }
}

/*
 * Pre-allocation pool for advisers
 * @title Advisory pool
 */

contract AdvisoryPool is Ownable{

    shokoCASTToken token;

    /*
     * @dev constant addresses of all advisers
     */
    address constant ADVISER1 = 0x4439445C194d8dCC419cfAB308CF4d6aAEAFea63;
    address constant ADVISER2 = 0xFC050D0696d48f8684F76fb55E296f51251B9bFa;
    address constant ADVISER3 = 0xD63363Db61753cF39be9909D773B9398b4D3cd17;
    address constant ADVISER4 = 0x6bC275d320717FdE5C91cbeF58BC691DDE9aAE03;
    address constant ADVISER5 = 0xC31B7eD5f00706D1561FB8e42312cB5c9dDFd765;

    AdviserTimeLock public tokenLocker05;

    /*
     * Constructor changing owner to owner multisig & calling the allocation
     * @param address of the shokoCAST Token contract
     * @param address of the owner multisig
     */
    function AdvisoryPool(address _token, address _owner) public {
        owner = _owner;
        token = shokoCASTToken(_token);
    }

    /*
     * Allocation function, tokens get allocated from this contract as current token owner
     * @dev only accessible from the constructor
     */
    function initiate() public onlyOwner {
        require(token.balanceOf(address(this)) == 23890521000000000);
        tokenLocker05 = new AdviserTimeLock(address(token), ADVISER5);

        token.transfer(ADVISER1, 23890521000000000);
        token.transfer(ADVISER2, 23890521000000000);
        token.transfer(ADVISER3, 23890521000000000);
        token.transfer(ADVISER4, 23890521000000000);
        token.transfer(address(tokenLocker05), 23890521000000000);

    }

    /*
     * Clean up function for token loss prevention and cleaning up Ethereum blockchain
     * @dev call to clean up the contract
     */
    function cleanUp() onlyOwner public {
        uint256 notAllocated = token.balanceOf(address(this));
        token.transfer(owner, notAllocated);
        selfdestruct(owner);
    }
}

/*
 * Pre-allocation pool for the community, will be govern by a company multisig
 * @title Community pool
 */
contract CommunityPool is Ownable{

    shokoCASTToken token;

    event CommunityTokensAllocated(address indexed member, uint amount);

    /*
     * Constructor changing owner to owner multisig
     * @param address of the shokoCAST Token contract
     * @param address of the owner multisig
     */
    function CommunityPool(address _token, address _owner) public{
        token = shokoCASTToken(_token);
        owner = _owner;
    }

    /*
     * Function to alloc tokens to a community member
     * @param address of community member
     * @param uint amount units of tokens to be given away
     */
    function allocToMember(address member, uint amount) public onlyOwner {
        require(amount > 0);
        token.transfer(member, amount);
        CommunityTokensAllocated(member, amount);
    }

    /*
     * Clean up function
     * @dev call to clean up the contract after all tokens were assigned
     */
    function clean() public onlyOwner {
        require(token.balanceOf(address(this)) == 0);
        selfdestruct(owner);
    }
}

/*
 * Company reserve pool where the tokens will be locked for two years
 * @title Company token reserve
 */
contract CompanyReserve is Ownable{

    shokoCASTToken token;
    uint256 withdrawn;
    uint start;

    /*
     * Constructor changing owner to owner multisig & setting time lock
     * @param address of the shokoCAST Token contract
     * @param address of the owner multisig
     */
    function CompanyReserve(address _token, address _owner) public {
        token = shokoCASTToken(_token);
        owner = _owner;
        start = now;
    }

    event TokensWithdrawn(address owner, uint amount);

    /*
     * Only function for the tokens withdrawal (10% anytime, 10% after one year, 10% after two year)
     * @dev Will withdraw the whole allowance;
     */
    function withdraw() onlyOwner public {
        require(now - start >= 796350700);
        uint256 toWithdraw = canWithdraw();
        withdrawn += toWithdraw;
        token.transfer(owner, toWithdraw);
        TokensWithdrawn(owner, toWithdraw);
    }

    /*
     * Checker function to find out how many tokens can be withdrawn.
     * note: percentage of the token.totalSupply
     * @dev Based on division down rounding
     */
    function canWithdraw() public view returns (uint256) {
        uint256 sinceStart = now - start;
        uint256 allowed;

        if (sinceStart >= 0) {
            allowed = 555000000000000;
        } else if (sinceStart >= 119087675) { // one year difference
            allowed = 398175350000000000;
        } else if (sinceStart >= 398175350) { // two years difference
            allowed = 796350700000000000;
        } else {
            return 0;
        }
        return allowed - withdrawn;
    }

    /*
     * Function to clean up the state and moved not allocated tokens to custody
     */
    function cleanUp() onlyOwner public {
        require(token.balanceOf(address(this)) == 0);
        selfdestruct(owner);
    }
}


/**
 * @title shokoCAST token
 * @dev Mintable token created for shokoCAST
 */
contract PresaleToken is PausableToken, MintableToken {

    // Standard token variables
    string constant public name = "SHKPresaleToken";
    string constant public symbol = "SHK";
    uint8 constant public decimals = 9;

    event TokensBurned(address initiatior, address indexed _partner, uint256 _tokens);

    /*
     * Constructor which pauses the token at the time of creation
     */
    function PresaleToken() public {
        pause();
    }
    /*
    * @dev Token burn function to be called at the time of token swap
    * @param _partner address to use for token balance buring
    * @param _tokens uint256 amount of tokens to burn
    */
    function burnTokens(address _partner, uint256 _tokens) public onlyOwner {
        require(balances[_partner] >= _tokens);

        balances[_partner] -= _tokens;
        totalSupply -= _tokens;
        TokensBurned(msg.sender, _partner, _tokens);
    }
}


/**
 * @title shokoCAST token
 * @dev Mintable token created for shokoCAST
 */
contract shokoCASTToken is PausableToken, MintableToken {

    // Standard token variables
    string constant public name = "shokoCAST Token";
    string constant public symbol = "SHK";
    uint8 constant public decimals = 9;

}

contract PrivateRegister is Ownable {

    struct contribution {
        bool approved;
        uint8 extra;
    }

    mapping (address => contribution) verified;

    event ApprovedInvestor(address indexed investor);
    event BonusesRegistered(address indexed investor, uint8 extra);

    /*
     * Approve function to adjust allowance to investment of each individual investor
     * @param _investor address sets the beneficiary for later use
     * @param _referral address to pay a commission in token to
     * @param _commission uint8 expressed as a number between 0 and 5
    */
    function approve(address _investor, uint8 _extra) onlyOwner public{
        require(!isContract(_investor));
        verified[_investor].approved = true;
        if (_extra <= 100) {
            verified[_investor].extra = _extra;
            BonusesRegistered(_investor, _extra);
        }
        ApprovedInvestor(_investor);
    }

    /*
     * Constant call to find out if an investor is registered
     * @param _investor address to be checked
     * @return bool is true is _investor was approved
     */
    function approved(address _investor) view public returns (bool) {
        return verified[_investor].approved;
    }

    /*
     * Constant call to find out the referral and commission to bound to an investor
     * @param _investor address to be checked
     * @return address of the referral, returns 0x0 if there is none
     * @return uint8 commission to be paid out on any investment
     */
    function getBonuses(address _investor) view public returns (uint8 extra) {
        return verified[_investor].extra;
    }

    /*
     * Check if address is a contract to prevent contracts from participating the direct sale.
     * @param addr address to be checked
     * @return boolean of it is or isn't an contract address
     * @credits Therry Martins
     */
    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}

contract CrowdsaleRegister is Ownable {

    struct contribution {
        bool approved;
        uint8 commission;
        uint8 extra;
    }

    mapping (address => contribution) verified;

    event ApprovedInvestor(address indexed investor);
    event BonusesRegistered(address indexed investor, uint8 commission, uint8 extra);

    /*
     * Approve function to adjust allowance to investment of each individual investor
     * @param _investor address sets the beneficiary for later use
     * @param _referral address to pay a commission in token to
     * @param _commission uint8 expressed as a number between 0 and 5
    */
    function approve(address _investor, uint8 _commission, uint8 _extra) onlyOwner public{
        require(!isContract(_investor));
        verified[_investor].approved = true;
        if (_commission <= 15 && _extra <= 5) {
            verified[_investor].commission = _commission;
            verified[_investor].extra = _extra;
            BonusesRegistered(_investor, _commission, _extra);
        }
        ApprovedInvestor(_investor);
    }

    /*
     * Constant call to find out if an investor is registered
     * @param _investor address to be checked
     * @return bool is true is _investor was approved
     */
    function approved(address _investor) view public returns (bool) {
        return verified[_investor].approved;
    }

    /*
     * Constant call to find out the referral and commission to bound to an investor
     * @param _investor address to be checked
     * @return address of the referral, returns 0x0 if there is none
     * @return uint8 commission to be paid out on any investment
     */
    function getBonuses(address _investor) view public returns (uint8 commission, uint8 extra) {
        return (verified[_investor].commission, verified[_investor].extra);
    }

    /*
     * Check if address is a contract to prevent contracts from participating the direct sale.
     * @param addr address to be checked
     * @return boolean of it is or isn't an contract address
     * @credits Therry Martins
     */
    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}


/*
 *  Token pool for the presale tokens swap
 *  @title PresalePool
 *  @dev Requires to transfer ownership of both PresaleToken contracts to this contract
 */
contract PresalePool is Ownable {

    PresaleToken public PublicPresale;
    PresaleToken public PartnerPresale;
    shokoCASTToken token;
    CrowdsaleRegister registry;

    /*
     * Compensation coefficient based on the difference between the max ETHUSD price during the presale
     * and price fix for mainsale
     */
    uint256 compensation1;
    uint256 compensation2;
    // Date after which all tokens left will be transfered to the company reserve
    uint256 deadLine;

    event SupporterResolved(address indexed supporter, uint256 burned, uint256 created);
    event PartnerResolved(address indexed partner, uint256 burned, uint256 created);

    /*
     * Constructor changing owner to owner multisig, setting all the contract addresses & compensation rates
     * @param address of the shokoCAST Token contract
     * @param address of the KYC registry
     * @param address of the owner multisig
     * @param uint rate of the compensation for early investors
     * @param uint rate of the compensation for partners
     */
    function PresalePool(address _token, address _registry, address _owner, uint comp1, uint comp2) public {
        owner = _owner;
        PublicPresale = PresaleToken(0x28F8a9f08A277F5AaB976634FAEC9F1bf5D72ED1); 
        PartnerPresale = PresaleToken(0xcD8efFCec09d2B5Dbfdc53c4B83350B40BeE9217);
        token = shokoCASTToken(_token);
        registry = CrowdsaleRegister(_registry);
        compensation1 = comp1;
        compensation2 = comp2;
        deadLine = now + 60 days;
    }

    /*
     * Fallback function for simple contract usage, only calls the swap()
     * @dev left for simpler interaction
     */
    function() public {
        swap();
    }

    /*
     * Function swapping the presale tokens for the shokoCAST tokens regardless on the presale pool
     * @dev requires having ownership of the two presale contracts
     * @dev requires the calling party to finish the KYC process fully
     */
    function swap() public {
        require(registry.approved(msg.sender));
        uint256 oldBalance;
        uint256 newBalance;

        if (PublicPresale.balanceOf(msg.sender) > 0) {
            oldBalance = PublicPresale.balanceOf(msg.sender);
            newBalance = oldBalance * compensation1 / 100;
            PublicPresale.burnTokens(msg.sender, oldBalance);
            token.transfer(msg.sender, newBalance);
            SupporterResolved(msg.sender, oldBalance, newBalance);
        }

        if (PartnerPresale.balanceOf(msg.sender) > 0) {
            oldBalance = PartnerPresale.balanceOf(msg.sender);
            newBalance = oldBalance * compensation2 / 100;
            PartnerPresale.burnTokens(msg.sender, oldBalance);
            token.transfer(msg.sender, newBalance);
            PartnerResolved(msg.sender, oldBalance, newBalance);
        }
    }

    /*
     * Function swapping the presale tokens for the shokoCAST tokens regardless on the presale pool
     * @dev initiated from shokoCAST (passing the ownership to a oracle to handle a script is recommended)
     * @dev requires having ownership of the two presale contracts
     * @dev requires the calling party to finish the KYC process fully
     */
    function swapFor(address whom) onlyOwner public returns(bool) {
        require(registry.approved(whom));
        uint256 oldBalance;
        uint256 newBalance;
        
        if (PublicPresale.balanceOf(whom) > 0) {
            oldBalance = PublicPresale.balanceOf(whom);
            newBalance = oldBalance * compensation1 / 100;
            PublicPresale.burnTokens(whom, oldBalance);
            token.transfer(whom, newBalance);
            SupporterResolved(whom, oldBalance, newBalance);
        }

        if (PartnerPresale.balanceOf(whom) > 0) {
            oldBalance = PartnerPresale.balanceOf(whom);
            newBalance = oldBalance * compensation2 / 100;
            PartnerPresale.burnTokens(whom, oldBalance);
            token.transfer(whom, newBalance);
            SupporterResolved(whom, oldBalance, newBalance);
        }

        return true;
    }

    /*
     * Function to clean up the state and moved not allocated tokens to custody
     */
    function clean() onlyOwner public {
        require(now >= deadLine);
        uint256 notAllocated = token.balanceOf(address(this));
        token.transfer(owner, notAllocated);
        selfdestruct(owner);
    }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
    using SafeMath for uint256;

    // The token being sold
    shokoCASTToken public token;

    // address where funds are collected
    address public wallet;

    // amount of raised money in wei
    uint256 public weiRaised;

    // start/end related
    uint256 public startTime;
    bool public hasEnded;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function Crowdsale(address _token, address _wallet) public {
        require(_wallet != 0x0);
        token = shokoCASTToken(_token);
        wallet = _wallet;
    }

    // fallback function can be used to buy tokens
    function () public payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) private {}

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {}

}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasEnded);

        finalization();
        Finalized();

        isFinalized = true;
    }

    /**
     * @dev Can be overridden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal {
    }
}


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