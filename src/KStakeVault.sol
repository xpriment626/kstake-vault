// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import { VmExtended } from "../lib/vm-extended/src/VmExtended.sol";
import { IKlerosV2 } from "./interfaces/IKlerosV2.sol";
import { IERC20 } from "../lib/vm-extended/src/interfaces/IERC20.sol";
import { IUniswapV2Router } from "./interfaces/IUniswapV2Router.sol";

error UnAuthoerised();

contract KStakeVault is VmExtended {

    IUniswapV2Router public router = IUniswapV2Router(UNI_V2_ROUTER);
    IKlerosV2 public kleros = IKlerosV2(KLEROS_LIQ);
    IERC20 public pnk = IERC20(KLEROS_PNK);
    mapping(address => bool) public trusted;
    uint256 private threshold;
    address private owner;
    uint256 private pnkCache;

    event PNKSwap(uint256 indexed _amountIn, address _tokenIn, uint256 indexed _timestamp);
    event StakeKleros(uint256 indexed _amount, uint96 indexed _subCourt);
    event PNKtoPool(uint256 indexed _amount);

    modifier onlyOwner {
        if (msg.sender != owner) revert UnAuthoerised();
        _;
    }
    constructor(uint256 _threshold) {
        owner = msg.sender;
        threshold = _threshold;
    }
    function tokenSwapToStake(
        address _tokenAddress, 
        uint256 _amount,
        uint96 _subcourtId) external onlyOwner {

        IERC20 token = IERC20(_tokenAddress);
        token.transferFrom(msg.sender, address(this), _amount);
        token.approve(UNI_V2_ROUTER, _amount);

        (uint256 reserveA, uint256 reserveB) = router.getReserves(UNI_V2_FACTORY, _tokenAddress, KLEROS_PNK);

        uint256 minAmountOut = router.getAmountOut(
            _amount, 
            reserveA, 
            reserveB);

        address[] memory path;
        path = new address[](2);
        path[0] = _tokenAddress;
        path[1] = KLEROS_PNK;

        uint256 deadline = block.timestamp + 30 seconds;

        router.swapExactTokensForTokens(
            _amount, 
            minAmountOut, 
            path, 
            msg.sender, 
            deadline);

        emit PNKSwap(
            _amount, 
            _tokenAddress, 
            block.timestamp);

        uint256 balance = pnk.balanceOf(msg.sender);

        pnk.transferFrom(msg.sender, KLEROS_LIQ, balance);
        pnk.approve(KLEROS_LIQ, balance);

        kleros.setStake(_subcourtId, balance);

        emit StakeKleros(balance, _subcourtId);
    }

    function poolFunds(uint256 _amount) external onlyOwner {
        uint256 balance = pnk.balanceOf(msg.sender);
        require(balance >= _amount, "insufficient PNK");
        pnkCache += _amount;

        pnk.transferFrom(msg.sender, address(this), _amount);
        pnk.approve(KLEROS_LIQ, _amount);

        emit PNKtoPool(_amount);
    }

}
