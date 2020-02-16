/**
 *Submitted for verification at Etherscan.io on 2019-05-31
*/

pragma solidity ^0.5.8;

import "./KittyCore.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

/// @title Main contract for WrappedCK. This contract converts Cryptokitties between the ERC721 standard and the
///  ERC20 standard by locking cryptokitties into the contract and minting 1:1 backed ERC20 tokens, that
///  can then be redeemed for cryptokitties when desired.
/// @notice When wrapping a cryptokitty, you get a generic WCK token. Since the WCK token is generic, it has no
///  no information about what cryptokitty you submitted, so you will most likely not receive the same kitty
///  back when redeeming the token unless you specify that kitty's ID. The token only entitles you to receive 
///  *a* cryptokitty in return, not necessarily the *same* cryptokitty in return. A different user can submit
///  their own WCK tokens to the contract and withdraw the kitty that you originally deposited. WCK tokens have
///  no information about which kitty was originally deposited to mint WCK - this is due to the very nature of 
///  the ERC20 standard being fungible, and the ERC721 standard being nonfungible.
contract WrappedCK is ERC20, ReentrancyGuard {

    // OpenZeppelin's SafeMath library is used for all arithmetic operations to avoid overflows/underflows.
    using SafeMath for uint256;

    /* ****** */
    /* EVENTS */
    /* ****** */

    /// @dev This event is fired when a user deposits cryptokitties into the contract in exchange
    ///  for an equal number of WCK ERC20 tokens.
    /// @param kittyId  The cryptokitty id of the kitty that was deposited into the contract.
    event DepositKittyAndMintToken(
        uint256 kittyId
    );

    /// @dev This event is fired when a user deposits WCK ERC20 tokens into the contract in exchange
    ///  for an equal number of locked cryptokitties.
    /// @param kittyId  The cryptokitty id of the kitty that was withdrawn from the contract.
    event BurnTokenAndWithdrawKitty(
        uint256 kittyId
    );

    /* ******* */
    /* STORAGE */
    /* ******* */

    /// @dev An Array containing all of the cryptokitties that are locked in the contract, backing
    ///  WCK ERC20 tokens 1:1
    /// @notice Some of the kitties in this array were indeed deposited to the contract, but they
    ///  are no longer held by the contract. This is because withdrawSpecificKitty() allows a 
    ///  user to withdraw a kitty "out of order". Since it would be prohibitively expensive to 
    ///  shift the entire array once we've withdrawn a single element, we instead maintain this 
    ///  mapping to determine whether an element is still contained in the contract or not. 
    uint256[] private depositedKittiesArray;

    /// @dev A mapping keeping track of which kittyIDs are currently contained within the contract.
    /// @notice We cannot rely on depositedKittiesArray as the source of truth as to which cats are
    ///  deposited in the contract. This is because burnTokensAndWithdrawKitties() allows a user to 
    ///  withdraw a kitty "out of order" of the order that they are stored in the array. Since it 
    ///  would be prohibitively expensive to shift the entire array once we've withdrawn a single 
    ///  element, we instead maintain this mapping to determine whether an element is still contained 
    ///  in the contract or not. 
    mapping (uint256 => bool) private kittyIsDepositedInContract;

    /* ********* */
    /* CONSTANTS */
    /* ********* */

    /// @dev The metadata details about the "Wrapped CryptoKitties" WCK ERC20 token.
    uint8 constant public decimals = 18;
    string constant public name = "Wrapped CryptoKitties";
    string constant public symbol = "WCK";

    /// @dev The address of official CryptoKitties contract that stores the metadata about each cat.
    /// @notice The owner is not capable of changing the address of the CryptoKitties Core contract
    ///  once the contract has been deployed.
    address public kittyCoreAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    KittyCore kittyCore;

    address public contractOwner;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /// @notice Allows a user to lock cryptokitties in the contract in exchange for an equal number
    ///  of WCK ERC20 tokens.
    /// @param _kittyIds  The ids of the cryptokitties that will be locked into the contract.
    /// @notice The user must first call approve() in the Cryptokitties Core contract on each kitty
    ///  that thye wish to deposit before calling depositKittiesAndMintTokens(). There is no danger 
    ///  of this contract overreaching its approval, since the CryptoKitties Core contract's approve() 
    ///  function only approves this contract for a single Cryptokitty. Calling approve() allows this 
    ///  contract to transfer the specified kitty in the depositKittiesAndMintTokens() function.
    function depositKittiesAndMintTokens(uint256[] calldata _kittyIds) external nonReentrant {
        require(_kittyIds.length > 0, 'you must submit an array with at least one element');
        for(uint i = 0; i < _kittyIds.length; i++){
            uint256 kittyToDeposit = _kittyIds[i];
            require(msg.sender == kittyCore.ownerOf(kittyToDeposit), 'you do not own this cat');
            require(kittyCore.kittyIndexToApproved(kittyToDeposit) == address(this), 'you must approve() this contract to give it permission to withdraw this cat before you can deposit a cat');
            kittyCore.transferFrom(msg.sender, address(this), kittyToDeposit);
            _pushKitty(kittyToDeposit);
            emit DepositKittyAndMintToken(kittyToDeposit);
        }
        _mint(msg.sender, (_kittyIds.length).mul(10**18));
    }

    /// @notice Allows a user to burn WCK ERC20 tokens in exchange for an equal number of locked 
    ///  cryptokitties.
    /// @param _kittyIds  The IDs of the kitties that the user wishes to withdraw. If the user submits 0 
    ///  as the ID for any kitty, the contract uses the last kitty in the array for that kitty.
    /// @param _destinationAddresses  The addresses that the withdrawn kitties will be sent to (this allows 
    ///  anyone to "airdrop" kitties to addresses that they do not own in a single transaction).
    function burnTokensAndWithdrawKitties(uint256[] calldata _kittyIds, address[] calldata _destinationAddresses) external nonReentrant {
        require(_kittyIds.length == _destinationAddresses.length, 'you did not provide a destination address for each of the cats you wish to withdraw');
        require(_kittyIds.length > 0, 'you must submit an array with at least one element');

        uint256 numTokensToBurn = _kittyIds.length;
        require(balanceOf(msg.sender) >= numTokensToBurn.mul(10**18), 'you do not own enough tokens to withdraw this many ERC721 cats');
        _burn(msg.sender, numTokensToBurn.mul(10**18));
        
        for(uint i = 0; i < numTokensToBurn; i++){
            uint256 kittyToWithdraw = _kittyIds[i];
            if(kittyToWithdraw == 0){
                kittyToWithdraw = _popKitty();
            } else {
                require(kittyIsDepositedInContract[kittyToWithdraw] == true, 'this kitty has already been withdrawn');
                require(address(this) == kittyCore.ownerOf(kittyToWithdraw), 'the contract does not own this cat');
                kittyIsDepositedInContract[kittyToWithdraw] = false;
            }
            kittyCore.transfer(_destinationAddresses[i], kittyToWithdraw);
            emit BurnTokenAndWithdrawKitty(kittyToWithdraw);
        }
    }

    /// @notice Adds a locked cryptokitty to the end of the array
    /// @param _kittyId  The id of the cryptokitty that will be locked into the contract.
    function _pushKitty(uint256 _kittyId) internal {
        depositedKittiesArray.push(_kittyId);
        kittyIsDepositedInContract[_kittyId] = true;
    }

    /// @notice Removes an unlocked cryptokitty from the end of the array
    /// @notice The reason that this function must check if the kittyIsDepositedInContract
    ///  is that the withdrawSpecificKitty() function allows a user to withdraw a kitty
    ///  from the array out of order.
    /// @return  The id of the cryptokitty that will be unlocked from the contract.
    function _popKitty() internal returns(uint256){
        require(depositedKittiesArray.length > 0, 'there are no cats in the array');
        uint256 kittyId = depositedKittiesArray[depositedKittiesArray.length - 1];
        depositedKittiesArray.length--;
        while(kittyIsDepositedInContract[kittyId] == false){
            kittyId = depositedKittiesArray[depositedKittiesArray.length - 1];
            depositedKittiesArray.length--;
        }
        kittyIsDepositedInContract[kittyId] = false;
        return kittyId;
    }

    /// @notice Removes any kitties that exist in the array but are no longer held in the
    ///  contract, which happens if the first few kitties have previously been withdrawn 
    ///  out of order using the withdrawSpecificKitty() function.
    /// @notice This function exists to prevent a griefing attack where a malicious attacker
    ///  could call withdrawSpecificKitty() on a large number of kitties at the front of the
    ///  array, causing the while-loop in _popKitty to always run out of gas.
    /// @param _numSlotsToCheck  The number of slots to check in the array.
    function batchRemoveWithdrawnKittiesFromStorage(uint256 _numSlotsToCheck) external {
        require(_numSlotsToCheck <= depositedKittiesArray.length, 'you are trying to batch remove more slots than exist in the array');
        uint256 arrayIndex = depositedKittiesArray.length;
        for(uint i = 0; i < _numSlotsToCheck; i++){
            arrayIndex = arrayIndex.sub(1);
            uint256 kittyId = depositedKittiesArray[arrayIndex];
            if(kittyIsDepositedInContract[kittyId] == false){
                depositedKittiesArray.length--;
            } else {
                return;
            }
        }
    }

    /// @notice The owner is not capable of changing the address of the CryptoKitties Core
    ///  contract once the contract has been deployed.
    ///  RBH the above is a goddamn lie now bitches
    constructor(address _kittyCoreAddress) public {
        contractOwner = msg.sender;
        setKittyCoreAddress(_kittyCoreAddress);
    }

    function setKittyCoreAddress(address _kittyCoreAddress) public {
        require(msg.sender == contractOwner, "Must be owner");
        kittyCoreAddress = _kittyCoreAddress;
        kittyCore = KittyCore(_kittyCoreAddress);
    }

    function changeOwner(address _newOwner) public {
        require(msg.sender == contractOwner, "Must be owner");
        contractOwner = _newOwner;
    }

    function getOwner() public view returns(address) {
        return contractOwner;
    }

    /// @dev We leave the fallback function payable in case the current State Rent proposals require
    ///  us to send funds to this contract to keep it alive on mainnet.
    /// @notice There is no function that allows the contract creator to withdraw any funds sent
    ///  to this contract, so any funds sent directly to the fallback function that are not used for 
    ///  State Rent are lost forever.
    function() external payable {}
}
