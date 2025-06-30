// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Ptak.sol";
import "./SpeciesLibrary.sol";

contract Park {
    Ptak public ptakContract;

    address public owner;

    constructor(address _ptakAddress) {
        ptakContract = Ptak(_ptakAddress);
        owner = msg.sender;
    }

    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }

    function healBird(uint256 birdId) external payable {
        require(msg.value >= 0.005 ether, "Healing costs 0.005 ETH");
        ptakContract.healBird(birdId);
    }

    function buyInsurance(uint256 birdId) external payable {
        require(msg.value >= 0.02 ether, "Insurance costs 0.02 ETH");
        ptakContract.insure(birdId);
    }

    function reviveBird(uint256 birdId) external payable {
        Ptak.BirdData memory bird = ptakContract.getBird(birdId);
        require(bird.isDead, "Bird is not dead");

        uint256 basePrice = SpeciesLibrary.getSpeciesPrice(bird.species);
        uint256 revivePrice = basePrice * 5;

        uint256 daysDead = (block.timestamp - bird.deathTimestamp) / 1 days;
        revivePrice += (revivePrice * daysDead) / 100;

        require(msg.value >= revivePrice, "Not enough ETH to revive this bird");

        ptakContract.revive(birdId);
    }

    function feedBird(uint256 birdId, uint256 amount) external payable {
        uint256 costPerUnit = 0.00001 ether;
        uint256 totalCost = amount * costPerUnit;

        require(msg.value >= totalCost, "Not enough ETH to feed");

        ptakContract.feedBird(birdId, amount);
    }



    function mintRegularBird(SpeciesLibrary.Species species) external payable {
        uint256 price = SpeciesLibrary.getSpeciesPrice(species);
        require(msg.value >= price, "Not enough ETH to mint this species");

        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 1000;
        if(rand < 10) { // 1% szans
            ptakContract.mintBird(SpeciesLibrary.Species.Mythical);
        }
        else{
            ptakContract.mintBird(species);
        }
    }

    function mintLegendaryBird() external payable {
        uint256 price = 0.2 ether;
        require(msg.value >= price, "Not enough ETH to mint mythical bird");
            ptakContract.mintBird(SpeciesLibrary.Species.Mythical);
    }
}
