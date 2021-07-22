// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint);
}

interface IKeep3rV1 {
    function isKeeper(address) external returns (bool);
    function worked(address keeper) external;
}

interface IYERC20 {
    function rebalance() external;
    function balanceOf(address account) external view returns (uint);
    function token() external view returns (address);
    function calcPoolValueInToken() external view returns (uint);
}

contract YearnV1EarnKeep3r {
    using SafeMath for uint;

    uint constant public THRESHOLD = 500;
    uint constant public BASE = 10000;

    IYERC20[] internal _tokens;

    constructor() public {
        _tokens.push(IYERC20(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e));
        _tokens.push(IYERC20(0x83f798e925BcD4017Eb265844FDDAbb448f1707D));
        _tokens.push(IYERC20(0x73a052500105205d34Daf004eAb301916DA8190f));
        _tokens.push(IYERC20(0xC2cB1040220768554cf699b0d863A3cd4324ce32));
        _tokens.push(IYERC20(0x26EA744E5B887E5205727f55dFBE8685e3b21951));
        _tokens.push(IYERC20(0xE6354ed5bC4b393a5Aad09f21c46E101e692d447));
        _tokens.push(IYERC20(0x04bC0Ab673d88aE9dbC9DA2380cB6B79C4BCa9aE));
    }

    function tokens() external view returns (IYERC20[] memory) {
        return _tokens;
    }

    modifier upkeep() {
        require(KP3R.isKeeper(msg.sender), "::isKeeper: keeper is not registered");
        _;
        KP3R.worked(msg.sender);
    }

    IKeep3rV1 public constant KP3R = IKeep3rV1(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);

    function workable() public view returns (bool) {
        for (uint i = 0; i < _tokens.length; i++) {
            if (shouldRebalance(_tokens[i])) {
                return true;
            }
        }
        return false;
    }

    function shouldRebalance(IYERC20 _token) public view returns (bool) {
        uint _total = _token.calcPoolValueInToken();
        uint _available = IERC20(_token.token()).balanceOf(address(_token));
        return _available >= _total.mul(THRESHOLD).div(BASE);
    }

    function work() external upkeep {
        require(workable(), "YearnV1EarnKeep3r::work: !workable()");
        for (uint i = 0; i < _tokens.length; i++) {
            if (shouldRebalance(_tokens[i])) {
                _tokens[i].rebalance();
            }
        }
    }
}
