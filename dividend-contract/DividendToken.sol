// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol";

/** @dev Replace _CONTRACT_NAME with your contract name, and "IDXX" with your token name. */
contract DividendToken is ERC20 {

    using EnumerableSet for EnumerableSet.UintSet;
    EnumerableSet.UintSet private _tokenAddress;

    /** @dev The amount of dividends that can now be distributed in the contract
     */
    uint256 public DividendNum = 0;

    /** @dev the starting amount of dividends
     */
    uint256 public immutable DividendBeginNum = 10**18;

    unit256 public immutable _decimals = 10;

    constructor(uint256 initialSupply) ERC20("DividendToken", "DT") {
        uint256 _totalSupply = initialSupply * 10**uint256(decimals()); // total issuance
        _mint(msg.sender, _totalSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        _tokenAddress.add(uint256(uint160(to)));
    }

    /** @dev return the dividend pool
     */
    function PoolNum() public view returns (uint256) {
        return address(this).balance;
    }

    event DividendsTo(
        address indexed toAddress,
        uint256 dividendsNum,
        uint256 lastPool
    );
    
    function TryDividends() public {
        uint256 thisBalance = address(this).balance;
        require(
            thisBalance >= DividendBeginNum,
            "There is not enough money in the current prize pool"
        );
        uint256 curBalance = thisBalance;
        uint256 totalSupply = totalSupply();
        for (uint256 index = 0; index < _tokenAddress.length(); index++) {
            address dividendTo = address(uint160(_tokenAddress.at(index)));
            uint256 heldNum = balanceOf(dividendTo);
            if (heldNum > 0) {
                uint256 dividendNum = heldNum * (thisBalance / totalSupply);
                if (dividendNum > 0) {
                    emit heldNumEvent(dividendTo, heldNum);
                    if (curBalance < dividendNum) {
                        break;
                    }
                    curBalance -= dividendNum;
                    payable(dividendTo).transfer(dividendNum);
                    emit DividendsTo(dividendTo, dividendNum, curBalance);
                }
            }
        }
    }

}