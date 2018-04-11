pragma solidity ^0.4.11;
import '../zeppelin/contracts/token/MintableToken.sol';
import '../zeppelin/contracts/token/PausableToken.sol';

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
