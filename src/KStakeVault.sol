// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import { VmExtended } from "../lib/vm-extended/src/VmExtended.sol";
import { IKlerosV2 } from "./interfaces/IKlerosV2.sol";
import { IWETH10 } from "./interfaces/IWETH10.sol";
import { IERC20 } from "../lib/vm-extended/src/interfaces/IERC20.sol";
import { IUniswapV2Router } from "./interfaces/IUniswapV2Router.sol";

error UnAuthoerised();

contract KStakeVault is VmExtended {

    IUniswapV2Router public router = IUniswapV2Router(UNI_V2_ROUTER);
    IKlerosV2 public kleros = IKlerosV2(KLEROS_LIQ);
    IERC20 public pnk = IERC20(KLEROS_PNK);
    IWETH10 public weth = IWETH10(fetchWETH(ETHEREUM));
    mapping(address => bool) public trusted;

    uint256 private threshold;
    address private owner;

    event PNKSwap(uint256 indexed _amount, uint256 indexed _timestamp);
    event WETHDeposit(uint256 indexed _amount, uint256 indexed _timestamp);
    event StakeKleros(uint256 indexed _amount, uint256 indexed _subCourt);

    modifier onlyOwner {
        if (msg.sender != owner) revert UnAuthoerised();
        _;
    }
    constructor(uint256 _threshold) {
        owner = msg.sender;
        threshold = _threshold;
    }

}
