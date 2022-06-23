pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Claim is ERC1155, Ownable {
  
   struct Item {
      uint256 itemId;
      string ipfsHash;
    }

    mapping (uint256 => Item) public items;
    mapping (address => uint256[]) public claimList;
  

    constructor () ERC1155("https://s3.us-east-1.amazonaws.com/cdn.digard.io/Eldarune/Airdrop/1.json"){}

    function getItems(uint256 itemId_) public view returns(uint256 itemId, string memory ipfsHash){
        return (items[itemId_].itemId, items[itemId_].ipfsHash);
    }

    function getUnClaimByAddress(address walletAddress) public view returns (uint256[] memory)
    {
        require(contains(walletAddress)==true, "Item cannot be claimed to this account.");
        return claimList[walletAddress];
    }
 
    function registerItems(Item[] memory newItems) public onlyOwner {
        for (uint256 i=0; i < newItems.length; i++) 
        { 
            items[newItems[i].itemId] = newItems[i];
        }
    }

  
    function claim() public  
    {
        require(claimList[msg.sender].length>0, "There are no items to claim for the account.");
        for (uint256 i=0; i < claimList[msg.sender].length; i++)
        {
            _mint(msg.sender, claimList[msg.sender][i], 1, "");
        }
        delete claimList[msg.sender];
    }

    function contains(address _wallet) internal view returns (bool){
            if(claimList[_wallet].length > 0){
                return true;
            }
            return false;
    }

    function addClaimItem(address walletAddress, uint256 itemId) external onlyOwner {
        require(balanceOf(walletAddress, itemId) == 0, "This account already has this entity");
        require(contains(walletAddress)==false, "Item cannot be claimed to this account.");
        claimList[walletAddress].push(itemId);
    }

    function burnItem(address walletAddress, uint256 id, uint256 amount) external onlyOwner {
        _burn(walletAddress, id, amount);
    }
}