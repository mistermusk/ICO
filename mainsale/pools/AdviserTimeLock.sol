pragma solidity ^0.4.20;

import '../../zeppelin/contracts/ownership/Ownable.sol';
import '../shokoCASTToken.sol';

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
