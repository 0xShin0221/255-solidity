// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.16;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol';

contract SampleERC20Wrapper is ERC20, ERC20Permit, ERC20Wrapper, ERC20Votes {
    constructor(
        IERC20 wrappedToken
    ) ERC20('QB', 'QB') ERC20Permit('GovernorToken') ERC20Wrapper(wrappedToken) {}

    // The functions below are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }

    function decimals() public view virtual override(ERC20Wrapper, ERC20) returns (uint8) {
        try IERC20Metadata(address(underlying)).decimals() returns (uint8 value) {
            return value;
        } catch {
            return super.decimals();
        }
    }
}
