// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import './ERC721.sol';
import './interfaces/IERC721Enumerable.sol';
contract ERC721Enumerable is ERC721, IERC721Enumerable {
     
    
    
    
    uint256[] private _allTokens;
    //mapping from tokenId to position in _allTokens array
    mapping (uint256 => uint256) private _allTokensIndex;
    //mapping of owner to list of all owner's token ids
    mapping(address => uint256[]) private _ownedTokens;
    //mapping from token ID to index of the owner's token list
    mapping(uint256 => uint256) private _ownedTokensIndex;
    constructor(){
        _registerInterface(bytes4(keccak256('totalSupply(bytes4)')^
        keccak256('tokenByIndex(bytes4)')^keccak256('tokenOfOwnerByIndex(bytes4)')));
    }
    
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256){
        return _allTokens.length;
    }

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256){
        //make sure that the index is not out of bounds of the total supply 
        require(_index < _allTokens.length,'Index is out of bounds');
        return _allTokens[_index];
    }

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){
        //make sure that index isn't out of bounds
        require(_index < this.balanceOf(_owner) ,'owner index out of bounds.');
        return _ownedTokens[_owner][_index];
    }
    function _mint(address to, uint256 tokenId) internal override(ERC721){
        super._mint(to, tokenId);
        //A. add tokens to the owner
        //B. all tokens to our total supply - to allTokens
        _addTokensToAllTokensEnumeration(tokenId);
        _addTokensToOwnerEnumeration(to, tokenId);
    }
    function _addTokensToAllTokensEnumeration(uint256 tokenId) private{
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);

    }
    function _addTokensToOwnerEnumeration(address to, uint256 tokenId) private{
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }
}