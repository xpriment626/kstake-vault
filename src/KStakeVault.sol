// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import { VmExtended } from "../lib/vm-extended/src/VmExtended.sol";
import { IKlerosV2 } from "./interfaces/IKlerosV2.sol";
import { IERC20 } from "../lib/vm-extended/src/interfaces/IERC20.sol";

contract KStakeVault is VmExtended {
    IKlerosV2 public kleros = IKlerosV2(KLEROS_LIQ);
    IERC20 public pnk = IERC20(KLEROS_PNK);
    IERC20 public weth = IERC20(fetchWETH(ETHEREUM));
}
