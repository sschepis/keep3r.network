// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

interface IChainLinkFeed {
    function latestAnswer() external view returns (int256);
}

interface IKeep3rV1 {
    function totalBonded() external view returns (uint);
    function bonds(address keeper, address credit) external view returns (uint);
    function votes(address keeper) external view returns (uint);
}

interface IUniswapV2SlidingOracle {
    function current(address tokenIn, uint amountIn, address tokenOut) external view returns (uint);
}

contract Keep3rV1Helper {
    using SafeMath for uint;

    IChainLinkFeed public constant FASTGAS = IChainLinkFeed(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C);
    IKeep3rV1 public constant KP3R = IKeep3rV1(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);
    IUniswapV2SlidingOracle public constant UV2SO = IUniswapV2SlidingOracle(0x73353801921417F465377c8d898c6f4C0270282C);
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    uint constant public MAX = 11;
    uint constant public BASE = 10;
    uint constant public SWAP = 300000;
    uint constant public TARGETBOND = 200e18;

    function quote(uint eth) public view returns (uint) {
        return UV2SO.current(address(WETH), eth, address(KP3R));
    }

    function getFastGas() external view returns (uint) {
        return uint(FASTGAS.latestAnswer());
    }

    function bonds(address keeper) public view returns (uint) {
        return KP3R.bonds(keeper, address(KP3R)).add(KP3R.votes(keeper));
    }

    function getQuoteLimitFor(address origin, uint gasUsed) public view returns (uint) {
        uint _min = quote((gasUsed.add(SWAP)).mul(uint(FASTGAS.latestAnswer())));
        uint _boost = _min.mul(MAX).div(BASE);
        uint _bond = Math.min(bonds(origin), TARGETBOND);
        return Math.max(_min, _boost.mul(_bond).div(TARGETBOND));
    }

    function getQuoteLimit(uint gasUsed) external view returns (uint) {
        return getQuoteLimitFor(tx.origin, gasUsed);
    }
}
