// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import './ERC721Connector.sol';
contract Ediz is ERC721Connector{
    string[] public ediz_stash; 
    //we were checking if the token has already been minted so here we're gonna check if the token exists in the array
    mapping(string => bool) elementExists;
    
    function mint(string memory element) public{
        //checking if the element was minted before       
        require(!elementExists[element],'Error - token already exists');
        //adding an element to the array
        ediz_stash.push(element);
        uint _id = ediz_stash.length -1;
        _mint(msg.sender, _id);
        elementExists[element] = true;
    }
    function getEdizArray() public view returns(string [] memory){
        return ediz_stash;
    }
    
    
    constructor() ERC721Connector('Edizz','Edo'){
        
    }
    
    
}