pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./KittyCore.sol";
import "./WrappedCK.sol";
import "./Dai.sol";

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

    address public daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    Dai public dai;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    constructor(
        address _kittyCoreAddress,
        address payable _wrappedCKAddress,
        address _daiAddress
    ) public {
        setKittyCoreAddress(_kittyCoreAddress);
        setWrappedCKAddress(_wrappedCKAddress);
        setDaiAddress(_daiAddress);
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

    function setDaiAddress(address _address) public onlyOwner {
        daiAddress = _address;
        dai = Dai(_address);
    }

    /* ********** */
    /* GAME LOGIC */
    /* ********** */

    struct Boss {
        uint256 bossId;
        uint256 traits;
        uint256 kittiesSlayed;
        uint16 originalHealth;
        uint16 health;
        uint16 element;
        uint16 bossType;
        uint16 originalCritDefense;
        uint16 critDefense;
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
        uint16 bossType,
        uint16 critDefense
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

    uint16 public MAX_HEALTH = 200;
    uint16 public MIN_HEALTH = 75;


    /***********/
    /* CONFIGS */
    /***********/
    function setBossMinHealth(uint16 _minHealth) public onlyOwner {
        require(_minHealth > 0, "min health must be > 0");
        MIN_HEALTH = _minHealth;
    }

    function setBossMaxHealth(uint16 _maxHealth) public onlyOwner {
        require(_maxHealth > MIN_HEALTH, "max health must be > min");
        MAX_HEALTH = _maxHealth;
    }


    Boss[] public bosses;
    Boss public currentBoss;

    struct HistoryRecord {
        uint256 bossId;
        uint256 kittyId;
        uint16 damage;
        bool criticalHit;
        bool winner;
    }

    struct History {
        uint256 bossId;
        uint256 startIndex;
        uint256 recordLength;
    }

    History[] public history;
    HistoryRecord[] public records;

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

    function computeDamage(
        uint256 _kittyId,
        uint16 _chai,
        uint16 _daiquiri,
        uint16 _daisake
    ) private returns(
        uint16 damage,
        bool hasCriticalHit
    ) {
        KittyStats memory stats = decodeKitty(_kittyId);

        uint16 elementMultiplier = computeElementMultiplier(
            currentBoss.element,
            stats.element
        );

        // Start the calculation with the base attack
        uint256 totalAttackDamage = uint256(stats.attack);

        // Determine if a critical hit occurs
        hasCriticalHit = uint16(notrandom(currentBoss.kittiesSlayed) * CRITICAL_CAP) <= stats.critical;

        if (stats.critical >= currentBoss.critDefense) {
            hasCriticalHit = true;
            currentBoss.critDefense = currentBoss.originalCritDefense;
        } else {
            currentBoss.critDefense = uint16(uint256(currentBoss.critDefense).sub(uint256(stats.critical)));
        }

    // PAY BONUSES
        // Multiply by the chai bonus
        totalAttackDamage = totalAttackDamage * (_chai + _daiquiri + _daisake + 1);

        // Daiquiri gives speed boost
        stats.speed *= (_daiquiri + 1);

        // Instant crit + elemental multiplier for daisake
        if (_daisake > 0) {
            hasCriticalHit = true;
            elementMultiplier *= 2;
        }
    // END PAY BONUSES

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

        damage = uint16(totalAttackDamage);
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

        /*
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
        */

        KittyStats memory stats = KittyStats(
            uint16(uint16(_kittyId % 2**16) % NUM_ELEMENTS),
            uint16(uint16(_kittyId % 2**16) % ATTACK_CAP),
            uint16(uint16(_kittyId % 2**16) % SPEED_CAP),
            uint16(uint16(_kittyId % 2**16) % CRITICAL_CAP)
        );

        if (stats.attack == 0) {
            stats.attack = 1;
        }

        if (stats.speed == 0) {
            stats.speed = 1;
        }

        if (stats.critical == 0) {
            stats.critical = 1;
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

        uint16 critDefense = uint16(((traits / 2**46) & 0xffff) % 99 + 12); // 110 max

        uint256 bossId = bosses.length;

        // Save the boss
        currentBoss = Boss(
            bossId,
            traits,
            0,
            health,
            health,
            uint16((traits / 2**14) & 0xffff % NUM_ELEMENTS),
            uint16((traits / 2**30) & 0xffff % NUM_BOSS_TYPES),
            critDefense,
            critDefense
        );

        bosses.push(currentBoss);

        history.push(History(
            bossId,
            (bossId == 0) ? 0 : history[bossId-1].startIndex + history[bossId-1].recordLength,
            0
        ));

        emit BossAppears(
            currentBoss.bossId,
            currentBoss.traits,
            currentBoss.health,
            currentBoss.element,
            currentBoss.bossType,
            currentBoss.critDefense
        );
    }

    // 0.005 eth ==  5 finney, approx $1.40 today
    // 0.020 eth == 20 finney, approx $5.60 today
    // 0.035 eth == 35 finney, approx $9.80 today
    uint256 public CHAI_COST_ETH     =  5 finney;
    uint256 public DAIQUIRI_COST_ETH = 20 finney;
    uint256 public DAISAKE_COST_ETH  = 35 finney;

    function setBonusCostsEth(
        uint256 _chai,
        uint256 _daiquiri,
        uint256 _daisake
    ) public onlyOwner {
        require(_chai > 100000000000000 && _daiquiri > _chai && _daisake > _daiquiri, "max health must be > min");
        CHAI_COST_ETH     = _chai;
        DAIQUIRI_COST_ETH = _daiquiri;
        DAISAKE_COST_ETH  = _daisake;
    }

    function getBonusCostsEth() public returns (uint256 chai, uint256 daiquiri, uint256 daisake) {
        chai = CHAI_COST_ETH;
        daiquiri = DAIQUIRI_COST_ETH;
        daisake = DAISAKE_COST_ETH;
    }

    // "ether" is just used to make the numbers look cleaner. It's in dollars.
    uint256 public CHAI_COST_DAI     =  1 ether;
    uint256 public DAIQUIRI_COST_DAI =  5 ether;
    uint256 public DAISAKE_COST_DAI  = 10 ether;

    function setBonusCostsDai(
        uint256 _chai,
        uint256 _daiquiri,
        uint256 _daisake
    ) public onlyOwner {
        require(_chai > 100000000000000 && _daiquiri > _chai && _daisake > _daiquiri, "max health must be > min");
        CHAI_COST_DAI     = _chai;
        DAIQUIRI_COST_DAI = _daiquiri;
        DAISAKE_COST_DAI  = _daisake;
    }

    function getBonusCostsDai() public returns (uint256 chai, uint256 daiquiri, uint256 daisake) {
        chai = CHAI_COST_DAI;
        daiquiri = DAIQUIRI_COST_DAI;
        daisake = DAISAKE_COST_DAI;
    }

    uint256 wrappedCKPot;
    uint256 daiPot;
    uint256 ethPot;

    function sacrifice(
            uint256 _kittyId,
            uint16 _chai,
            uint16 _daiquiri,
            uint16 _daisake,
            uint256 _daiAmount
    ) public payable nonReentrant {
        require(msg.sender == kittyCore.ownerOf(_kittyId), 'you do not own this cat');
        require(kittyCore.kittyIndexToApproved(_kittyId) == address(this), 'you must approve() this contract');

        uint256 expectedValueEth = 0;
        uint256 expectedValueDai = 0;

        if (_chai > 0) {
            if (_chai > 5) {
                _chai = 5;
            }
            expectedValueEth += _chai * CHAI_COST_ETH;
            expectedValueDai += _chai * CHAI_COST_DAI;
        }

        if (_daiquiri > 0) {
            if (_daiquiri > 5) {
                _daiquiri = 5;
            }
            expectedValueEth += _daiquiri * DAIQUIRI_COST_ETH;
            expectedValueDai += _daiquiri * DAIQUIRI_COST_DAI;
        }

        if (_daisake > 0) {
            if (_daisake > 5) {
                _daisake = 5;
            }
            expectedValueEth += _daisake * DAISAKE_COST_ETH;
            expectedValueDai += _daisake * DAISAKE_COST_DAI;
        }

        if (_daiAmount > 0) {
            // check the correct amount of dai
            require(_daiAmount == expectedValueDai, "did not pay correct dai for items");

            // approve the transaction
            //(bool success, bytes memory result) = daiAddress.delegatecall(abi.encodeWithSignature("approve(address,uint256)", address(this), _daiAmount));
            //require(success, "could not approve dai tx");

            // transfer the dai
            bool daiTransferSuccess = dai.transferFrom(msg.sender, address(this), _daiAmount);

            // make sure it worked
            require(daiTransferSuccess, "could not transfer dai");

            daiPot += _daiAmount * 9 / 10;
        } else {
            require(msg.value == expectedValueEth, "did not pay correct eth for items");
            ethPot += msg.value * 9 / 10;
        }

        if (evaluateDamage(_kittyId, _chai, _daiquiri, _daisake)) {
            emit BossDefeated(
                block.number,
                _kittyId,
                kittyCore.ownerOf(_kittyId)
            );
            releasePrize();
            createNewBoss();
        } else {
            wrappedCKPot += 10**18 * 9 / 10;
            currentBoss.kittiesSlayed += 1;
            wrap(_kittyId);
        }
    }

    function releasePrize() private {
        // Transfer WCKs to the winner
        uint256 reward = wrappedCK.balanceOf(address(this)) * 9 / 10;
        reward = (wrappedCKPot <= reward) ? wrappedCKPot : reward;
        wrappedCK.transfer(msg.sender, wrappedCKPot);
        wrappedCKPot = 0;

        // Transfer DAI to the winner
        uint256 rewardDai = dai.balanceOf(address(this)) * 9 / 10;
        rewardDai = (daiPot <= rewardDai) ? daiPot : rewardDai;
        dai.approve(msg.sender, rewardDai);
        dai.transfer(msg.sender, rewardDai);
        daiPot = 0;

        // Transfer ETH to the winner
        uint256 amount = address(this).balance * 9 / 10;
        amount = (ethPot <= amount) ? ethPot : amount;
        msg.sender.transfer(amount);
        ethPot = 0;
    }

    function evaluateDamage(
        uint256 _kittyId,
        uint16 _chai,
        uint16 _daiquiri,
        uint16 _daisake
    ) private returns(bool) {
        (uint16 damage, bool hasCriticalHit) = computeDamage(_kittyId, _chai, _daiquiri, _daisake);

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

        bool defeated = currentBoss.health == 0;

        records.push(HistoryRecord(
            currentBoss.bossId, _kittyId, damage, hasCriticalHit, defeated
        ));
        history[currentBoss.bossId].recordLength += 1;

        return defeated;
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

    /**
     * Allow the owner to withdraw some or all of the contract balance.
     * Pass zero to withdraw all.
     */
    function withdraw (uint256 _amountRequested) external onlyOwner {
        uint256 amount = address(this).balance;

        // If the caller has asked for too much, or has asked for zero,
        // send the entire balance.
        if ((_amountRequested > 0) && (_amountRequested < amount)) {
            amount = _amountRequested;
        }

        // owner() is not address payable, but msg.sender is and is *guaranteed*
        // to be owner(). So use msg.sender here.
        msg.sender.transfer(amount);
    }
}
