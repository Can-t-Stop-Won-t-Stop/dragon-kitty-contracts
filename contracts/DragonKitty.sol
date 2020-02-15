pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./KittyCore.sol";
import "./WrappedCK.sol";

contract DragonKitty is Ownable, ReentrancyGuard {

    // OpenZeppelin's SafeMath library is used for all arithmetic operations to avoid overflows/underflows.
    using SafeMath for uint256;

    /// @dev some garbo, probably not needed, but it's funny af
    string constant public name = "dieKittyDai";
    string constant public symbol = "DKD";

    address public kittyCoreAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    KittyCore kittyCore;

    address public wrappedCKAddress = 0x09fE5f0236F0Ea5D930197DCE254d77B04128075;
    WrappedCK wrappedCK;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    constructor(address _kittyCoreAddress, address payable _wrappedCKAddress) public {
        setKittyCoreAddress(_kittyCoreAddress);
        setWrappedCKAddress(_wrappedCKAddress);
        createNewBoss();
    }

    function setKittyCoreAddress(address _address) public onlyOwner {
        kittyCoreAddress = _address;
        kittyCore = KittyCore(_address);
    }

    function setWrappedCKAddress(address payable _address) public onlyOwner {
        wrappedCKAddress = _address;
        wrappedCK = WrappedCK(_address);
    }

    /* ********** */
    /* GAME LOGIC */
    /* ********** */

    function createNewBoss() private nonReentrant {

    }

    function sacrifice(uint256 _kittyId) public nonReentrant {
        require(msg.sender == kittyCore.ownerOf(_kittyId), 'you do not own this cat');
        require(kittyCore.kittyIndexToApproved(_kittyId) == address(this), 'you must approve() this contract');

        if (evaluate(_kittyId)) {
            releasePrize();
            createNewBoss();
        } else {
            wrap(_kittyId);
        }
    }

    function releasePrize() private nonReentrant {
        // Transfer WCKs to the winner
        uint256 reward = (wrappedCK.balanceOf(address(this)) * 9) / 10;
        wrappedCK.transfer(msg.sender, reward);
    }

    function evaluate(uint256 _kittyId) private returns(bool) {
        return false;
    }

    function wrap(uint256 _kittyId) private {
        // First transfer the kitty to this contract
        kittyCore.transferFrom(msg.sender, address(this), _kittyId);

        // Then this contract approves another transfer
        kittyCore.approve(wrappedCKAddress, _kittyId);

        // Finally this contract deposits and gets some dope-ass wrapped cats
        uint256[] memory kittyIds = new uint[](1);
        kittyIds[0] = _kittyId;
        wrappedCK.depositKittiesAndMintTokens(kittyIds);
    }
}
