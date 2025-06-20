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

    modifier onlyPark() {
        require(msg.sender == parkContract, "Only Park can call this");
        _;
    }

    constructor(address _parkContract) {
        parkContract = _parkContract;
    }

    function mintBird(SpeciesLibrary.Species species, string memory imageUrl) external onlyPark returns (int) {
        SpeciesLibrary.SpeciesInfo memory info = SpeciesLibrary.getSpeciesInfo(species);
        birds[nextId] = BirdData(0, 0, info.maxHealth, species);
        nextId++;
        return 0; // success
    }

    function updateHungerAndAge(uint256 id) public {
        BirdData storage bird = birds[id];
        uint256 timeElapsed = block.timestamp - bird.lastUpdateTime; // w sekundach
        if(timeElapsed > 0) {
            // hunger rośnie proporcjonalnie do czasu (nie tylko pełne godziny)
            uint256 hungerIncrease = (timeElapsed * SpeciesLibrary.getSpeciesInfo(bird.species).hungerDecayRate) / 3600;
            bird.hunger += hungerIncrease;

            uint256 maxHunger = SpeciesLibrary.getSpeciesInfo(bird.species).maxHunger;
            if(bird.hunger > maxHunger) {
                bird.hunger = maxHunger;
            }

            // starzenie: np. 1 dzień = 86400 sekund
            uint256 daysPassed = timeElapsed / 86400;
            if(daysPassed > 0) {
                bird.age += daysPassed;
            }

            bird.lastUpdateTime = block.timestamp; // aktualizujemy do bieżącego czasu
        }
    }

    function randomPoisoning(uint256 birdId) private {
        Ptak.BirdData memory bird = ptakContract.getBird(birdId);
        if(!insured[birdId]){
            uint256 chance = SpeciesLibrary.getSpeciesInfo(bird.species).poisoningChance;
            uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, birdId))) % 100;

            if(rand < chance) {
                bird.health -= 25;
            }
        }
    }

    function feedBird(uint256 id, uint256 foodAmount) external onlyPark {
        updateHungerAndAge(id); // najpierw update
        BirdData storage bird = birds[id];
        randomFoodPoisoning(id);
        if(bird.hunger >= foodAmount){
            bird.hunger -= foodAmount;
        } else {
            bird.hunger = 0; // minimalny głód to zero
        }
    }

    function getBird(uint256 id) external view returns (BirdData memory) {
        updateHungerAndAge(id);
        return birds[id];
    }

}
