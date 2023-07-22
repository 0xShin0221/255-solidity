//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

abstract contract ERC1155Vote is ERC1155Upgradeable {
    uint8 public constant MAX_LOAD = 8;

    // additional mapping of data to store vote load
    mapping(uint256 => uint256) private _tokens;

    modifier tokenOwner(uint256 tokenId) {
        require(
            ownerOf(tokenId) == msg.sender || isApprovedForAll(ownerOf(tokenId), msg.sender),
            "ERC1155Vote: not authorised"
        );
        _;
    }

    // ERC721 method
    function ownerOf(uint256 tokenId) public view returns (address) {
        return address(uint160(_data(tokenId)));
    }

    function voteLoad(uint256 tokenId) public view returns (uint256) {
        return uint256(uint8(_data(tokenId) >> 160));
    }

    function voteInfo(uint256 tokenId) public view returns (uint256, uint256[] memory) {
        uint256 data = _data(tokenId);
        uint256 load = uint256(uint8(data >> 160));
        uint256[] memory delegatedIds;

        // return tokenId & delegated votes
        if (load == 0) return (_delegatedTo(tokenId), delegatedIds);

        delegatedIds = new uint256[](load - 1);
        for (uint256 i = 0; i < load - 1; i++) {
            delegatedIds[i] = uint256(uint8(data >> (168 + (i * 8))));
        }

        return (tokenId, delegatedIds);
    }

    function delegateVote(uint256 fromTokenId, uint256 toTokenId) public tokenOwner(fromTokenId) {
        // redirected tokenId
        toTokenId = _delegatedTo(toTokenId);
        require(voteLoad(toTokenId) <= MAX_LOAD, "ERC1155Vote: cannot handle more vote load");

        // have load
        if (voteLoad(fromTokenId) > 1) {
            (, uint256[] memory ids) = voteInfo(fromTokenId);
            for (uint256 i = 0; i < ids.length; i++) {
                _resetDelegations(ids[i]);
            }
        }

        // decrease load
        _setData(fromTokenId, ownerOf(fromTokenId), uint96(0 | (toTokenId << 8)));

        // increase load
        _setData(
            toTokenId,
            ownerOf(toTokenId),
            uint96((_data(toTokenId) >> 160) | (fromTokenId << (voteLoad(toTokenId) * 8 + 160)))
        );
    }

    function recoverVote(uint256 tokenId) public tokenOwner(tokenId) {
        require(voteLoad(tokenId) != 0, "ERC1155Vote: non delegated token");

        // withdraw vote from delegate
        uint256 delegateToken = _delegatedTo(tokenId);

        // rewrite bitmap
        uint96 bitmap = uint96(voteLoad(delegateToken));
        (, uint256[] memory delegatedIds) = voteInfo(delegateToken);
        uint256 jump;
        for (uint256 i = 0; i < delegatedIds.length; i++) {
            if (delegatedIds[i] == tokenId) {
                jump++;
            }
            bitmap |= uint96(delegatedIds[i + jump] << (i * 8));
        }
        _setData(delegateToken, ownerOf(delegateToken), bitmap);
        _resetDelegations(tokenId);
    }

    function _delegatedTo(uint256 tokenId) internal view returns (uint256) {
        uint256 votingPower = uint256(uint8(tokenId >> 160));
        if (votingPower != 0) {
            return tokenId;
        } else {
            uint256 delegatedId = uint256(uint8(tokenId >> 168));
            return _delegatedTo(delegatedId);
        }
    }

    function _setData(
        uint256 tokenId,
        address owner,
        uint96 bitmap
    ) internal {
        _tokens[tokenId] = uint256(uint160(owner)) | (bitmap << 160);
    }

    // only callable when user have delegate vote and delegate to another one or when recoverVote is called
    function _resetDelegations(uint256 tokenId) internal {
        uint256 data = uint256(uint160(ownerOf(tokenId)));
        data |= 1 << 160;
        data |= tokenId << 168;
        _tokens[tokenId] = data;
    }

    function _data(uint256 tokenId) internal view returns (uint256) {
        return _tokens[tokenId];
    }
}
