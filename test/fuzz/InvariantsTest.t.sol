// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine engine;
    DecentralizedStableCoin dsc;
    HelperConfig config;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() external {
        DeployDSC deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        handler = new Handler(engine, dsc, config);
        targetContract(address(handler));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(engine));
        uint256 totalBtcDepoisted = IERC20(wbtc).balanceOf(address(engine));

        uint256 wethValue = engine.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = engine.getUsdValue(wbtc, totalBtcDepoisted);

        console.log("weth value:", wethValue);
        console.log("wbtc value:", wbtcValue);
        console.log("total supply:", totalSupply);
        console.log("times mint called:", handler.timesMintIsCalled());

        assert(wethValue + wbtcValue >= totalSupply);
    }

    // function invariant_gettersShouldNotRevert() public view {
    //     engine.getAccountCollateralValue();
    //     engine.getAccountInfo();
    // }
}
