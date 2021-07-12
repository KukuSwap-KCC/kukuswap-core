// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// KuKuBar is the coolest bar in town. You come in with some KUKU, and leave with more! The longer you stay, the more KUKU you get.
//
// This contract handles swapping to and from xKUKU, kukuswap's staking token.
contract KuKuBar is ERC20("KuKuBar", "xKUKU"){
    using SafeMath for uint256;
    IERC20 public KUKU;

    // Define the KUKU token contract
    constructor(IERC20 _KUKU) public {
        KUKU = _KUKU;
    }

    // Enter the bar. Pay some KUKUs. Earn some shares.
    // Locks KUKU and mints xKUKU
    function enter(uint256 _amount) public {
        // Gets the amount of KUKU locked in the contract
        uint256 totalKUKU = KUKU.balanceOf(address(this));
        // Gets the amount of xKUKU in existence
        uint256 totalShares = totalSupply();
        // If no xKUKU exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalKUKU == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of xKUKU the KUKU is worth. The ratio will change overtime, as xKUKU is burned/minted and KUKU deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalKUKU);
            _mint(msg.sender, what);
        }
        // Lock the KUKU in the contract
        KUKU.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your KUKUs.
    // Unlocks the staked + gained KUKU and burns xKUKU
    function leave(uint256 _share) public {
        // Gets the amount of xKUKU in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of KUKU the xKUKU is worth
        uint256 what = _share.mul(KUKU.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        KUKU.transfer(msg.sender, what);
    }
}
