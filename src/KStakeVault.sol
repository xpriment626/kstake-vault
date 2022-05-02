// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import { VmExtended } from "../lib/vm-extended/src/VmExtended.sol";
import { IKlerosV2 } from "./interfaces/IKlerosV2.sol";
import { IERC20 } from "../lib/vm-extended/src/interfaces/IERC20.sol";
import { IUniswapV2Router } from "./interfaces/IUniswapV2Router.sol";

error UnAuthorised();
error InsufficientBalance();
error BelowThreshold();

/**
* @title KStakeVault
* @author Emmett
* @dev This contract functions as a personal vault
*      that lets users stake directly to KlerosCore.
*/
contract KStakeVault is VmExtended {

    IUniswapV2Router public router = IUniswapV2Router(UNI_V2_ROUTER);
    IKlerosV2 public kleros = IKlerosV2(KLEROS_LIQ);
    IERC20 public pnk = IERC20(KLEROS_PNK);
    IERC20 public weth = IERC20(fetchWETH(ETHEREUM));
    address public owner;
    uint256 public pnkThreshold;
    uint256 public wethThreshold;

    event PNKSwap(uint256 indexed _amountIn, address indexed _tokenIn, uint256 indexed _timestamp);
    event StakeKleros(uint256 indexed _amount, uint96 indexed _subCourt);
    event PNKtoPool(uint256 indexed _amount, uint256 indexed _timestamp);
    event WETHtoPool(uint256 indexed _amount, uint256 indexed _timestamp);

    modifier onlyOwner {
        if (msg.sender != owner) revert UnAuthorised();
        _;
    }
    constructor(address _owner) {
        owner = _owner;
    }

    /// @param _minWeth sets the minimum amount of weth needed to execute a batch transaction
    /// @param _minPnk sets the minimum amount of pnk needed to execute a batch stake
    function setThresholds(uint256 _minWeth, uint256 _minPnk) external onlyOwner {
        pnkThreshold = _minPnk;
        wethThreshold = _minWeth;
    }

    /***************
        Tx Logic 
    ***************/

    /**
    * @dev This function lets the user swap any token 
    *      for pnk
    * @param _tokenAddress token to be swapped
    * @param _amount of tokens to swap
    * @param _subcourtId specify which subcourt to stake in 
    */
    function tokenSwapToStake(
        address _tokenAddress, 
        uint256 _amount,
        uint96 _subcourtId) external onlyOwner {

        IERC20 token = IERC20(_tokenAddress);
        token.transferFrom(msg.sender, address(this), _amount);
        token.approve(UNI_V2_ROUTER, _amount);

        /// @dev Reserves for both tokens must be computed before performing an exact token swap
        (uint256 reserveA, uint256 reserveB) = router.getReserves(UNI_V2_FACTORY, _tokenAddress, KLEROS_PNK);

        uint256 minAmountOut = router.getAmountOut(
            _amount, 
            reserveA, 
            reserveB);

        /// @dev sets an exact swap path to PNK
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

        /// @dev sends the newly purchased PNK straight to the subcourt specified in args
        uint256 balance = pnk.balanceOf(msg.sender);

        pnk.approve(KLEROS_LIQ, balance);
        pnk.transferFrom(msg.sender, KLEROS_LIQ, balance);

        kleros.setStake(_subcourtId, balance);

        emit StakeKleros(balance, _subcourtId);
    }

    /// @dev stakes all pnk in the contract if balance is equal to or above threshold
    function executePnkPool(uint96 _subcourtId) external onlyOwner {
        uint256 balance = pnk.balanceOf(address(this));
        if (balance < pnkThreshold) revert BelowThreshold();

        pnk.approve(KLEROS_LIQ, balance);
        pnk.transferFrom(address(this), KLEROS_LIQ, balance);

        kleros.setStake(_subcourtId, balance);
        emit StakeKleros(balance, _subcourtId);
    }

    /**
    * @dev swaps the contracts weth balance into pnk
    * @param _subcourtId specify where to stake pnk
    */
    function executeWethPool(uint96 _subcourtId) external onlyOwner {
        uint256 balance = weth.balanceOf(address(this));
        address wethAddress = fetchWETH(ETHEREUM);
        if (balance < wethThreshold) revert BelowThreshold();

        (uint256 reserveA, uint256 reserveB) = router.getReserves(UNI_V2_FACTORY, wethAddress, KLEROS_PNK);

        uint256 minAmountOut = router.getAmountOut(
            balance, 
            reserveA, 
            reserveB);

         /// @dev sets an exact swap path to PNK
        address[] memory path;
        path = new address[](2);
        path[0] = wethAddress;
        path[1] = KLEROS_PNK;

        uint256 deadline = block.timestamp + 30 seconds;

        router.swapExactTokensForTokens(
            balance, 
            minAmountOut, 
            path, 
            address(this), 
            deadline);
        
        emit PNKSwap(balance, wethAddress, block.timestamp);
        
        uint256 toStake = pnk.balanceOf(address(this));

        pnk.approve(KLEROS_LIQ, toStake);
        pnk.transferFrom(address(this), KLEROS_LIQ, toStake);

        kleros.setStake(_subcourtId, toStake);
        emit StakeKleros(toStake, _subcourtId);
    }

    /***************
       Pool Party
    ***************/

    /// @dev sends PNK to the contract for use in batch staking
    function poolPnk(uint256 _amount) external onlyOwner {
        uint256 balance = pnk.balanceOf(msg.sender);
        if (_amount > balance) revert InsufficientBalance();

        pnk.transferFrom(msg.sender, address(this), _amount);
        emit PNKtoPool(_amount, block.timestamp);
    }

    /// @dev sends WETH to the contract for use in batch swap & stake
    function poolWeth(uint256 _amount) external onlyOwner {
        uint256 balance = weth.balanceOf(msg.sender);
        if (_amount > balance) revert InsufficientBalance();

        weth.transferFrom(msg.sender, address(this), _amount);
        emit WETHtoPool(_amount, block.timestamp);
    }

}
