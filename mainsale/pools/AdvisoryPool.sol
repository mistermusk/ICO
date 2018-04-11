pragma solidity ^0.4.20;

import '../../zeppelin/contracts/ownership/Ownable.sol';
import '../shokoCASTToken.sol';
import './AdviserTimeLock.sol';

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
