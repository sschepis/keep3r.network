// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: reverted");
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: < 0");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: !contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: !succeed");
        }
    }
}

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

interface IKeep3rV1 {
    function isKeeper(address) external returns (bool);
    function worked(address keeper) external;
}


interface ICERC20 {
    function liquidateBorrow(address borrower, uint repayAmount, address cTokenCollateral) external returns (uint);
    function borrowBalanceStored(address account) external view returns (uint);
    function underlying() external view returns (address);
    function symbol() external view returns (string memory);
    function redeem(uint redeemTokens) external returns (uint);
    function balanceOf(address owner) external view returns (uint);
}

interface ICEther {
    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;
    function borrowBalanceStored(address account) external view returns (uint);
}

interface IComptroller {
    function getAccountLiquidity(address account) external view returns (uint, uint, uint);
    function closeFactorMantissa() external view returns (uint);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint reserve0, uint reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IWETH9 {
    function deposit() external payable;
}

contract CreamFlashLiquidate {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IComptroller constant public Comptroller = IComptroller(0x3d5BC3c8d13dcB8bF317092d84783c2697AE9258);
    IUniswapV2Factory constant public FACTORY = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IUniswapV2Router constant public ROUTER = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant public crETH = address(0xD06527D5e56A3495252A528C4987003b712860eE);

    modifier upkeep() {
        require(KP3R.isKeeper(msg.sender), "::isKeeper: keeper is not registered");
        _;
        KP3R.worked(msg.sender);
    }

    IKeep3rV1 public constant KP3R = IKeep3rV1(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);

    function getPair(address borrow) public view returns (address) {
        return FACTORY.getPair(borrow, WETH);
    }

    function calcRepayAmount(uint amount0, uint amount1) public view returns (uint) {
        (uint reserve0, uint reserve1, ) = _pair.getReserves();
        uint expected = reserve0.mul(reserve1);

        uint balance0 = IERC20(_pair.token0()).balanceOf(address(_pair));
        uint balance1 = IERC20(_pair.token1()).balanceOf(address(_pair));

        uint current = balance0.mul(balance1);

        uint val = 0;
        if (amount0 == 0) {
            val = amount1.mul(reserve0).div(reserve1);
        } else {
            val = amount0.mul(reserve1).div(reserve0);
        }

        uint fee = val.mul(31).div(10000);

        return (val.add(fee)).mul(expected).div(current);
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external {

        uint liquidatableAmount = (amount0 == 0 ? amount1 : amount0);

        uint256 err = ICERC20(_borrow).liquidateBorrow(_account, liquidatableAmount, _collateral);
        require(err == 0, "failed");

        uint256 liquidatedAmount = IERC20(_collateral).balanceOf(address(this));

        require(liquidatedAmount > 0, "failed");
        require(ICERC20(_collateral).redeem(ICERC20(_collateral).balanceOf(address(this))) == 0, "uniswapV2Call: redeem != 0");

        address underlying;
        if (_collateral == crETH) {
            underlying = WETH;
            IWETH9(WETH).deposit.value(address(this).balance)();
        } else {
            underlying = ICERC20(_collateral).underlying();
        }

        if (_borrow != _collateral) {
            if (underlying != WETH) {
                uint swap = IERC20(underlying).balanceOf(address(this));
                address[] memory path = new address[](2);
                    path[0] = address(underlying);
                    path[1] = address(WETH);

                IERC20(underlying).safeApprove(address(ROUTER), swap);
                ROUTER.swapExactTokensForTokens(swap, 0, path, address(this), now.add(1800));
            }
            uint repay = calcRepayAmount(amount0, amount1);
            require(IERC20(WETH).balanceOf(address(this)) > repay, "liquidate: WETH <= repay");
            IERC20(WETH).safeTransfer(address(_pair), repay);
            IERC20(WETH).safeTransfer(tx.origin, IERC20(WETH).balanceOf(address(this)));
        } else {
            IERC20(underlying).safeTransfer(address(_pair), liquidatableAmount.add(liquidatableAmount.mul(31).div(10000)));
            IERC20(underlying).safeTransfer(tx.origin, IERC20(underlying).balanceOf(address(this)));
        }



    }

    address internal _borrow;
    address internal _collateral;
    address internal _account;
    IUniswapV2Pair internal _pair;

    function () external payable { }

    function liquidate(address borrower, address cTokenBorrow, address cTokenCollateral) external {
        (,,uint256 shortFall) = Comptroller.getAccountLiquidity(borrower);
        require(shortFall > 0, "liquidate:shortFall == 0");

        uint256 liquidatableAmount = ICERC20(cTokenBorrow).borrowBalanceStored(borrower);

        require(liquidatableAmount > 0, "liquidate:borrowBalanceStored == 0");

        liquidatableAmount = liquidatableAmount.mul(Comptroller.closeFactorMantissa()).div(1e18);

        address underlying = ICERC20(cTokenBorrow).underlying();
        IUniswapV2Pair pair = IUniswapV2Pair(getPair(underlying));
        uint available = IERC20(underlying).balanceOf(address(pair));

        liquidatableAmount = Math.min(liquidatableAmount, available);
        require(liquidatableAmount > 0, "liquidate:liquidatableAmount == 0");
        IERC20(underlying).safeIncreaseAllowance(cTokenBorrow, liquidatableAmount);

        (uint _amount0, uint _amount1) = (underlying == pair.token0() ? (liquidatableAmount, uint(0)) : (uint(0), liquidatableAmount));

        _borrow = cTokenBorrow;
        _collateral = cTokenCollateral;
        _account = borrower;
        _pair = pair;

        pair.swap(_amount0, _amount1, address(this), abi.encode(msg.sender));
    }

    function liquidateCalculated(address borrower, IUniswapV2Pair pair, address underlying, uint amount, address repay, address collateral) external {
        IERC20(underlying).safeIncreaseAllowance(repay, amount);
        (uint _amount0, uint _amount1) = (underlying == pair.token0() ? (amount, uint(0)) : (uint(0), amount));

        _borrow = repay;
        _collateral = collateral;
        _account = borrower;

        pair.swap(_amount0, _amount1, address(this), abi.encode(msg.sender));
    }
}
