pragma solidity ^0.4.0;

import '../zeppelin/contracts/token/MintableToken.sol';
import '../zeppelin/contracts/token/PausableToken.sol';

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
