// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import { KStakeVault } from "../KStakeVault.sol";
import { VmExtended } from "../../lib/vm-extended/src/VmExtended.sol";
import { IERC20 } from "../../lib/vm-extended/src/interfaces/IERC20.sol";
contract KVaultTest is VmExtended {

    event WETHtoPool(uint256 indexed _amount, uint256 indexed _timestamp);
    event Logger(string);

    address public annie;
    IERC20 public weth;
    KStakeVault public vault;
    function setUp() public {
        (annie, weth) = initWithERC20(1, fetchWETH(ETHEREUM), 50000);
        vault = new KStakeVault(annie);
    }
    function testOwner() public {
        emit Logger("It should set owner as expected");

        address expected = annie;
        address owner = vault.owner();
        assertEq(expected, owner);
    }
    function testOwnerBalance() public {
        emit Logger("It should return the correct balance");

        uint256 expected = 50000;
        uint256 balance = weth.balanceOf(annie);
        assertEq(expected, balance);
    }
    function testWETHPooling() public {
        emit Logger("It should allow owner to pool WETH");

        uint256 val = 10000;
        vm_extended.startPrank(annie);
        weth.approve(address(vault), val);
        vm_extended.expectEmit(true, true, false, false);
        emit WETHtoPool(val, block.timestamp);
        vault.poolWeth(val);
        vm_extended.stopPrank();

        uint256 expected = val;
        uint256 balance = weth.balanceOf(address(vault));
        assertEq(expected, balance);
    }

    function testPoolUpdate() public {
        emit Logger("It should properly update cache value");
        
        uint256 newVal = 5000;
        uint256 balanceBefore = weth.balanceOf(address(vault));
        vm_extended.startPrank(annie);
        weth.approve(address(vault), newVal);
        vm_extended.expectEmit(true, true, false, false);
        emit WETHtoPool(newVal, block.timestamp);
        vault.poolWeth(newVal);
        vm_extended.stopPrank();

        uint256 expected = balanceBefore + newVal;
        uint256 balanceAfter = weth.balanceOf(address(vault));
        assertEq(expected, balanceAfter);
    }
}
