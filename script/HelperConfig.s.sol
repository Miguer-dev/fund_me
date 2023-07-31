// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    uint32 public constant CHAINID_GOERLI = 5;
    uint8 public constant CHAINID_ETHEREUM = 1;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == CHAINID_GOERLI) activeNetworkConfig = getGoerliEthConfig();
        else if (block.chainid == CHAINID_ETHEREUM) activeNetworkConfig = getEthereumEthConfig();
        else activeNetworkConfig = getOrCreateTestChainEthConfig();
    }

    function getGoerliEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory goerliConfig = NetworkConfig(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return goerliConfig;
    }

    function getEthereumEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethereumConfig = NetworkConfig(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        return ethereumConfig;
    }

    function getOrCreateTestChainEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) return activeNetworkConfig;

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator( DECIMALS, INITIAL_PRICE );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig(address(mockV3Aggregator));
        return anvilConfig;
    }
}
