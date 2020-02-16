pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

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

    struct Boss {
        uint256 bossId;
        uint256 traits;
        uint256 kittiesSlayed;
        uint16 health;
        uint16 element;
        uint16 bossType;
    }

    struct KittyStats {
        uint16 element;
        uint16 attack;
        uint16 speed;
        uint16 critical;
    }

    uint16 public ATTACK_CAP = 128;
    uint16 public SPEED_CAP = 64;
    uint16 public CRITICAL_CAP = 16;
    uint16 public NUM_ELEMENTS = 5;
    uint16 public NUM_BOSS_TYPES = 3;
    uint16 public CRITICAL_MULTIPLIER = 3;
    uint16 public TANK_CRITICAL_WEAKNESS = 2;

    event BossAppears(
        uint256 bossId,
        uint256 traits,
        uint16 health,
        uint16 element,
        uint16 bossType
    );

    event BossDefeated(
        uint256 indexed blockNumber,
        uint256 indexed kittyId,
        address indexed owner
    );

    event DamageInflicted(
        uint256 indexed bossId,
        uint256 indexed kittyId,
        address indexed owner,
        uint16 damage,
        uint16 healthRemaining
    );

    uint16 MAX_HEALTH = 200;
    uint16 MIN_HEALTH = 75;

    Boss[] public bosses;
    Boss public currentBoss;

    function notrandom(uint256 seed) private view returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    seed,
                    block.timestamp,
                    block.difficulty,
                    blockhash(block.number-1)
                )
            )
        );
    }

    function computeDamage(uint256 _kittyId) private view returns(uint16) {
        KittyStats memory stats = decodeKitty(_kittyId);

        uint16 elementMultiplier = computeElementMultiplier(
            currentBoss.element,
            stats.element
        );

        bool hasCriticalHit = uint16(notrandom(currentBoss.kittiesSlayed) * CRITICAL_CAP) < stats.critical;

        // Start the calculation with the base attack
        uint256 totalAttackDamage = uint256(stats.attack);

        // If critical, multiply
        if (hasCriticalHit) {
            totalAttackDamage = totalAttackDamage * CRITICAL_MULTIPLIER;
        }

        // Multiply by the total attack damage... (division to come)
        totalAttackDamage = totalAttackDamage * elementMultiplier;

        // Handle the boss type
        if (currentBoss.bossType == 1) {
            if (hasCriticalHit) {
                totalAttackDamage = totalAttackDamage * TANK_CRITICAL_WEAKNESS;
            }
        } else if (currentBoss.bossType == 2) {
            totalAttackDamage = (totalAttackDamage * stats.speed) / SPEED_CAP;
        }

        // Finally divide by the factor on the total attack damage
        totalAttackDamage = totalAttackDamage / elementDivisor;

        // Always do at least a minimum amount of damage
        if (totalAttackDamage < 1) {
            totalAttackDamage = 1;
        } else if (totalAttackDamage > 2**16) {
            totalAttackDamage = 2**16-1;
        }

        return uint16(totalAttackDamage);
    }

    // Divide by 10 because the elementMultiplier needs to be an integer
    uint16 elementDivisor = 10;

    function computeElementMultiplier(uint16 bossElement, uint16 kittyElement) private pure returns (uint16) {
        if ((bossElement + 1) % 5 == kittyElement) {
            return 5;
        } else if ((kittyElement + 1) % 5 == bossElement) {
            return 20;
        } else {
            return 10;
        }
    }

    function decodeKitty(uint256 _kittyId) public view returns (KittyStats memory) {
        // Get the genes
        uint256 genes = getGenes(_kittyId);

        KittyStats memory stats = KittyStats(
            uint16(uint16(genes & 0xffff) % NUM_ELEMENTS),
            uint16(uint16(genes / 2**16 & 0xffff) % ATTACK_CAP),
            uint16(uint16(genes / 2**32 & 0xffff) % SPEED_CAP),
            uint16(uint16(genes / 2**48 & 0xffff) % CRITICAL_CAP)
        );

        if (uint256(stats.attack) + uint256(stats.speed) + uint256(stats.critical) == 0) {
            stats = KittyStats(
                uint16(uint16(_kittyId % 2**16) % NUM_ELEMENTS),
                uint16(uint16(_kittyId % 2**16) % ATTACK_CAP),
                uint16(uint16(_kittyId % 2**16) % SPEED_CAP),
                uint16(uint16(_kittyId % 2**16) % CRITICAL_CAP)
            );
        }

        return stats;
    }

    function getGenes(uint256 _kittyId) public view returns (uint256) {
        (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        ) = kittyCore.getKitty(_kittyId);

        return genes;
    }

    function createNewBoss() private {
        require(currentBoss.health == 0, "current boss is still alive");

        // Generate the boss's traits
        uint256 traits = notrandom(bosses.length);
        uint16 health = uint16(traits % MAX_HEALTH);
        if (health < MIN_HEALTH) {
            health = MIN_HEALTH;
        }

        // Save the boss
        currentBoss = Boss(
            bosses.length,
            traits,
            0,
            health,
            uint16((traits / 2**14) & 0xffff % NUM_ELEMENTS),
            uint16((traits / 2**30) & 0xffff % NUM_BOSS_TYPES)
        );

        bosses.push(currentBoss);

        emit BossAppears(
            currentBoss.bossId,
            currentBoss.traits,
            currentBoss.health,
            currentBoss.element,
            currentBoss.bossType
        );
    }

    /***********/
    /* CONFIGS */
    /***********/
    function setBossMinHealth(uint16 _minHealth) public onlyOwner {
        require(_minHealth > 0, "min health must be > 0");
        MIN_HEALTH = _minHealth;
    }


    function sacrifice(uint256 _kittyId) public nonReentrant {
        require(msg.sender == kittyCore.ownerOf(_kittyId), 'you do not own this cat');
        require(kittyCore.kittyIndexToApproved(_kittyId) == address(this), 'you must approve() this contract');

        if (evaluateDamage(_kittyId)) {
            emit BossDefeated(
                block.number,
                _kittyId,
                kittyCore.ownerOf(_kittyId)
            );
            releasePrize();
            createNewBoss();
        } else {
            currentBoss.kittiesSlayed += 1;
            wrap(_kittyId);
        }
    }

    function releasePrize() private {
        // Transfer WCKs to the winner
        uint256 reward = wrappedCK.balanceOf(address(this));
        wrappedCK.transfer(msg.sender, reward);
    }

    function evaluateDamage(uint256 _kittyId) private returns(bool) {
        uint16 damage = computeDamage(_kittyId);

        if (damage >= currentBoss.health) {
            currentBoss.health = 0;
        } else {
            currentBoss.health = uint16(uint256(currentBoss.health).sub(uint256(damage)));
        }

        emit DamageInflicted(
            currentBoss.bossId,
            _kittyId,
            kittyCore.ownerOf(_kittyId),
            damage,
            currentBoss.health
        );

        return currentBoss.health == 0;
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
