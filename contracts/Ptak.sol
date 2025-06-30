// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SpeciesLibrary.sol";

contract Ptak {
    using SpeciesLibrary for SpeciesLibrary.Species;

    struct BirdData {
        uint256 age;
        uint256 hunger;
        uint256 health;
        SpeciesLibrary.Species species;
        uint256 lastUpdateTime;
        bool isDead;
        uint256 deathTimestamp;
    }

    mapping(uint256 => BirdData) public birds;
    uint256 public nextId;
    address public parkContract;
    mapping(uint256 => bool) public insured;
    mapping(uint256 => address) public ownerOf;


    modifier onlyPark() {
        require(msg.sender == parkContract, "Only Park can call this");
        _;
    }

    constructor(address _parkContract) {
        parkContract = _parkContract;
    }

    function mintBird(SpeciesLibrary.Species species) external onlyPark returns (uint) {
        SpeciesLibrary.SpeciesInfo memory info = SpeciesLibrary.getSpeciesInfo(species);
        birds[nextId] = BirdData(0, 0, info.maxHealth, species, block.timestamp, false, 0);
        ownerOf[nextId] = tx.origin;
        uint256 mintedId = nextId;
        nextId++;
        return mintedId;
    }

    function updateHungerAndAge(uint256 id) public {
        BirdData storage bird = birds[id];
        if (bird.isDead) return;

        uint256 timeElapsed = block.timestamp - bird.lastUpdateTime;
        if (timeElapsed > 0) {
            SpeciesLibrary.SpeciesInfo memory info = SpeciesLibrary.getSpeciesInfo(bird.species);

            uint256 hungerIncrease = (timeElapsed * info.hungerDecayRate) / 3600;
            bird.hunger += hungerIncrease;

            if (bird.hunger > info.maxHunger) {
                uint256 overflow = bird.hunger - info.maxHunger;
                bird.hunger = info.maxHunger;
                if (bird.health <= overflow) {
                    bird.health = 0;
                    bird.isDead = true;
                    bird.deathTimestamp = block.timestamp;
                } else {
                    bird.health -= overflow;
                }
            }

            uint256 daysPassed = timeElapsed / 86400;
            if (daysPassed > 0) {
                bird.age += daysPassed;
            }

            bird.lastUpdateTime = block.timestamp;
        }
    }

    function getBirdImage(uint256 birdId) external view returns (string memory) {
        BirdData storage bird = birds[birdId];
        return SpeciesLibrary.getSpeciesInfo(bird.species).imageUrl;
    }

    function healBird(uint256 birdId) external onlyPark {
        BirdData storage bird = birds[birdId];
        require(!bird.isDead, "Cannot heal a dead bird; revive it first");

        bird.health = SpeciesLibrary.getSpeciesInfo(bird.species).maxHealth;
    }

    function randomPoisoning(uint256 birdId) private {
        SpeciesLibrary.SpeciesInfo memory info;
        Ptak.BirdData storage bird = birds[birdId];
        info = SpeciesLibrary.getSpeciesInfo(bird.species);

        if(!insured[birdId]){
            uint256 chance = SpeciesLibrary.getSpeciesInfo(bird.species).poisoningChance;
            uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, birdId))) % 100;

            if(rand < chance) {
                bird.health -= 25;
            }
        }
    }

    function feedBird(uint256 id, uint256 foodAmount) external onlyPark {
        updateHungerAndAge(id);
        BirdData storage bird = birds[id];
        randomPoisoning(id);

        require(!bird.isDead, "Cannot feed a dead bird");

        if(bird.hunger >= foodAmount){
            bird.hunger -= foodAmount;
        } else {
            bird.hunger = 0;
        }
    }

    function revive(uint256 birdId) external onlyPark {
        BirdData storage bird = birds[birdId];
        require(bird.isDead, "Not dead");
        bird.health = SpeciesLibrary.getSpeciesInfo(bird.species).maxHealth;
        bird.hunger = 0;
        bird.isDead = false;
        bird.deathTimestamp = 0;
        bird.lastUpdateTime = block.timestamp;
    }

    function insure(uint256 birdId) external onlyPark {
        insured[birdId] = true;
    }

    function getBird(uint256 id) external returns (BirdData memory) {
        updateHungerAndAge(id);
        return birds[id];
    }

    function setParkContract(address _parkContract) external {
        require(parkContract == address(0), "Park already set");
        parkContract = _parkContract;
    }

    function transferBird(uint256 birdId, address newOwner) external onlyPark {
        require(ownerOf[birdId] == tx.origin, "Not the owner");
        require(newOwner != address(0), "Invalid address");
        ownerOf[birdId] = newOwner;
    }
}
