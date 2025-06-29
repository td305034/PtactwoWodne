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

    function mintBird(SpeciesLibrary.Species species) external onlyPark returns (int) {
        SpeciesLibrary.SpeciesInfo memory info = SpeciesLibrary.getSpeciesInfo(species);
        birds[nextId] = BirdData(0, 0, info.maxHealth, species, block.timestamp);
        ownerOf[nextId] = msg.sender;
        nextId++;
        return 0;
    }

    function updateHungerAndAge(uint256 id) public {
        BirdData storage bird = birds[id];
        uint256 timeElapsed = block.timestamp - bird.lastUpdateTime; // in seconds
        if(timeElapsed > 0) {
            uint256 hungerIncrease = (timeElapsed * SpeciesLibrary.getSpeciesInfo(bird.species).hungerDecayRate) / 3600;
            bird.hunger += hungerIncrease;

            uint256 maxHunger = SpeciesLibrary.getSpeciesInfo(bird.species).maxHunger;
            if(bird.hunger > maxHunger) {
                bird.hunger = maxHunger;
            }

            // starzenie
            uint256 daysPassed = timeElapsed / 86400;
            if(daysPassed > 0) {
                bird.age += daysPassed;
            }

            bird.lastUpdateTime = block.timestamp; // aktualizujemy do bieżącego czasu
        }
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
        if(bird.hunger >= foodAmount){
            bird.hunger -= foodAmount;
        } else {
            bird.hunger = 0;
        }
    }

    function insure(uint256 birdId) external {
        require(msg.sender == parkContract, "Only Park can insure");
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

    function transferBird(uint256 birdId, address newOwner) external {
        require(ownerOf[birdId] == msg.sender, "Not the owner");
        require(newOwner != address(0), "Invalid address");
        ownerOf[birdId] = newOwner;
    }
}
