pragma solidity ^0.4.20;

import '../../zeppelin/contracts/ownership/Ownable.sol';
import '../shokoCASTToken.sol';

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
