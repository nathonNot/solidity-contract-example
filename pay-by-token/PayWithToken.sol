// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract PayWithToken {

    address private owner;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    /**
     * @dev usdt token address on eth
     */
    IERC20 private constant Token = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    address private immutable Seller;
    
    /**
     * @dev Set contract deployer as owner
     * @param _seller The flow of funds at the time of purchase
     */
    constructor(address _seller) {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        Seller = _seller;
    }

    /**
     * @dev Change owner
     * @param useNumber address of new owner
     */
    function Buy(uint useNumber) public {
        _safeTransfer(msg.sender,Seller,useNumber);
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'PayWithToken: TRANSFER_FAILED');
    }
}