// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import './ERC165.sol';
import './interfaces/IERC721.sol';
/*
1-Minting NFTs:
    a. nft to point to an address
    b. keep track of the token ids
    c. keep track of token owner address to token ids
    d. keep track of how many tokens an owner address has
    e. create an event that emits a transfer log - contract address, where it is being minted to, the id.

*/

contract ERC721 is ERC165, IERC721{
    //event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    //event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    //event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

// Mapping from token id to token owner
    mapping(uint256 => address) private _tokenOwner;
// Mapping from owner to number of owned tokens
    mapping(address => uint256) private _OwnedTokensCount;
    //Mapping from token id to approved addresses
    mapping(uint256 => address) private _tokenApprovals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    
    constructor(){
        _registerInterface(bytes4(keccak256('balanceOf(bytes4)')^
        keccak256('ownerOf(bytes4)')^keccak256('transferFrom(bytes4)')));
    }
    
    
    
    
    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero

    function balanceOf(address _owner) external view returns(uint256){
        require(_owner != address(0),'owner query for non-existent token');
        return _OwnedTokensCount[_owner];
    }
    
    
    
    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address){
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), 'owner query for non-existent token');
        return owner; 
    }
    
    
    function _exist(uint256 tokenId) internal view returns(bool){
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }
    
    function _mint(address to, uint256 tokenId) internal virtual{
        //requires that the address isn't 0
        require(to != address(0), "ERC721: minting to the zero address");
        //requires that the token doesn't already exist
        require(!_exist(tokenId),'ERC721: token already minted');
        //we are adding a new address with a token id for minting
        _tokenOwner[tokenId] = to;
        _OwnedTokensCount[to] += 1;
        emit Transfer(address(0), to, tokenId);
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal{
        require(_to != address(0),'Error -- ERC721: Transfer to the zero address.');
        require(this.ownerOf(_tokenId) == _from,'Trying to transfer a token the address does not own.');
        _tokenOwner[_tokenId] = _to;
        _OwnedTokensCount[_to] +=1;
        _OwnedTokensCount[_from] -=1;
        emit Transfer(_from, _to, _tokenId);
    }
    //to make it safer:
    function transferFrom(address _from, address _to, uint256 _tokenId) public{
        require(isApprovedOrOwner(msg.sender,_tokenId),'ERC721: transfer caller is not owner nor approved');
        _transferFrom(_from,_to,_tokenId);
    }

    //1. require that the person approving is the owner -- by requiring the message sender to be the owner!
    //2. we are approving an address to a token (token ID)
    //3. require that we can't approve sending tokens of the owner to the owner (current caller)
    //4. update the map of the approval address
    function approve(address approved, uint256 tokenId) override public{
        require(msg.sender == this.ownerOf(tokenId), 'Current caller is not the owner.');
        require(approved != this.ownerOf(tokenId), 'Error- approval to current owner.');
        _tokenApprovals[tokenId] = approved;
        emit Approval(this.ownerOf(tokenId),approved,tokenId);
    }
    // get the approved address for that token
    function getApproved(uint256 tokenId) public view returns(address){
        return _tokenApprovals[tokenId];
    }
    // query to check if msg.sender is owner or approved of that token
    function isApprovedOrOwner(address spender,uint256 tokenId) public view returns(bool){
        require(_exist(tokenId),'ERC721: operator query for non-existent token');
        address owner = this.ownerOf(tokenId);
        return (owner == spender || getApproved(tokenId) == spender || isApprovedForAll(owner,spender)); 

    }
    //Owner approves operator to all of their assets
    function setApprovalForAll(address operator, bool approved) public{
        require(msg.sender!= operator,'ERC721: approve to caller.');
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    //Checking if the address(preferrably operator) is approved for all the assets
    function isApprovedForAll(address owner, address operator) public view returns(bool){
        return _operatorApprovals[owner][operator];
    }
}