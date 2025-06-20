// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Ptak.sol";
import "./SpeciesLibrary.sol";

contract Park {
    Ptak public ptakContract;
    mapping(uint256 => bool) public insured;
    mapping(SpeciesLibrary.Species => uint256) public speciesPrices;

    constructor(address _ptakAddress) {
        ptakContract = Ptak(_ptakAddress);
        speciesPrices[SpeciesLibrary.Species.MuteSwan] = 0.05 ether;
        speciesPrices[SpeciesLibrary.Species.WhiteStork] = 0.05 ether;
        speciesPrices[SpeciesLibrary.Species.MallardDuck] = 0.02 ether;
        speciesPrices[SpeciesLibrary.Species.GreyHeron] = 0.03 ether;
        speciesPrices[SpeciesLibrary.Species.RedNeckedGrebe] = 0.018 ether;
        speciesPrices[SpeciesLibrary.Species.WaterRail] = 0.01 ether;
        speciesPrices[SpeciesLibrary.Species.CommonTern] = 0.01 ether;
        speciesPrices[SpeciesLibrary.Species.Goosander] = 0.012 ether;
        speciesPrices[SpeciesLibrary.Species.GreylagGoose] = 0.04 ether;
        speciesPrices[SpeciesLibrary.Species.Moorhen] = 0.01 ether;
    }


    function ageBird(uint256 birdId) external {
        Ptak.BirdData memory bird = ptakContract.getBird(birdId);
    }

    function healBird(uint256 birdId) external payable {
        require(msg.value >= 0.005 ether, "Healing costs 0.005 ETH");
        Ptak.BirdData memory bird = ptakContract.getBird(birdId);
        bird.health = SpeciesLibrary.getSpeciesInfo(bird.species).maxHealth;
    }

    function buyInsurance(uint256 birdId) external payable {
        require(msg.value >= 0.02 ether, "Insurance costs 0.02 ETH");
        insured[birdId] = true;
    }

    function mintRegularBird(SpeciesLibrary.Species species) external payable {
        uint256 price = speciesPrices[species];
        require(msg.value >= price, "Not enough ETH to mint " + species);

        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 1000;
        if(rand < 10) { // 1% szans
            ptakContract.mintBird(SpeciesLibrary.Species.Mythical);
        }
        else{
            ptakContract.mintBird(species, imageUrl);
        }
    }

    function mintLegendaryBird(string memory imageUrl) external returns (int) {
        uint256 price = 0.2 ether;
        require(msg.value >= price, "Not enough ETH to mint mythical bird");
            ptakContract.mintBird(SpeciesLibrary.Species.Mythical);
    }
}
