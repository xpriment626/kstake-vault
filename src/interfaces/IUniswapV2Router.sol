// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
interface IUniswapV2Router {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getReserves(
        address factory, 
        address tokenA, 
        address tokenB
    ) external view returns (uint reserveA, uint reserveB);

    function getAmountOut(
        uint amountIn, 
        uint reserveIn, 
        uint reserveOut
    ) external pure returns (uint amountOut);

}