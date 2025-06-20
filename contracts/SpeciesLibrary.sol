// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library SpeciesLibrary {
    enum Species { 
        MuteSwan, 
        WhiteStork, 
        MallardDuck, 
        Mythical, 
        GreyHeron, 
        RedNeckedGrebe, 
        WaterRail, 
        CommonTern, 
        Goosander, 
        GreylagGoose, 
        Moorhen 
    }


    struct SpeciesInfo {
        uint256 maxHealth;       // the longer the ptak actually lives, the more health it gets here
        uint256 maxHunger;       // when hunger reaches maxHunger, the Ptak dies. When it gets below 0, it gets poisoned.
        uint256 hungerDecayRate; // this value is added to hunger every hour
        uint256 poisoningChance; // percentage (0-100)
        string imageUrl;
    }

    function getSpeciesInfo(Species species) internal pure returns (SpeciesInfo memory) {
        if (species == Species.MuteSwan) {
            return SpeciesInfo(200, 150, 3, 1, "https://gateway.pinata.cloud/ipfs/bafybeia3le4astknh2p4mbkd5w42j522tnse4wxk7w5m7wimoqdp6ouzpy");
        } else if (species == Species.WhiteStork) {
            return SpeciesInfo(220, 200, 2, 5, "https://gateway.pinata.cloud/ipfs/bafybeigohotok6k3onvtjyypfnbnzbcso2qcixbwz4wh64vp2n3lq7nksa");
        } else if (species == Species.MallardDuck) {
            return SpeciesInfo(80, 80, 3, 6, "https://gateway.pinata.cloud/ipfs/bafybeiev7pucz7yh7x6haidmphp5ieobvcfdclnlwjqa2ivs4y357pvwma");
        } else if (species == Species.Mythical) {
            return SpeciesInfo(300, 300, 1, 0, "");
        } else if (species == Species.GreyHeron) {
            return SpeciesInfo(180, 90, 2, 4, "");
        } else if (species == Species.RedNeckedGrebe) {
            return SpeciesInfo(80, 70, 2, 8, "");
        } else if (species == Species.WaterRail) {
            return SpeciesInfo(50, 60, 4, 5, "");
        } else if (species == Species.CommonTern) {
            return SpeciesInfo(55, 40, 3, 4, "");
        } else if (species == Species.Goosander) {
            return SpeciesInfo(78, 65, 2, 4, "");
        } else if (species == Species.GreylagGoose) {
            return SpeciesInfo(150, 100, 4, 3, "");
        } else if (species == Species.Moorhen) {
            return SpeciesInfo(35, 66, 4, 5, "");
        }
        revert("Unknown species");
    }

}