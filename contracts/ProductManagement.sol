// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Material_Managment.sol";

contract ProductManagement {
    struct Material {
        uint256 matId;
        address ownerId;
        uint256 cost;
    }

    struct Product {
        string name;
        uint256 price;
        uint256 quantity;
        uint256 status;
        Material[] materials;
    }

    mapping(uint256 => Product) public products;
    uint256 public productCount;
    MaterialManagement public materialContract;
    event ProductAdded(uint256 indexed productId, string name, uint256 quantity, uint256 price, uint256 status);


    constructor(address _materialContractAddress) {
        materialContract = MaterialManagement(_materialContractAddress);
    }

    function addProduct(string memory _name, uint256 _price, uint256 _quantity, uint256 _status, uint256[] memory _matIds, address[] memory _ownerIds, uint256[] memory _costs, uint256[] memory _qts) external payable returns (uint256) {
        productCount++;

        for (uint256 i = 0; i < _matIds.length; i++) {
            products[productCount].materials.push(Material(_matIds[i], _ownerIds[i], _costs[i]));
            materialContract.setQuantity(_matIds[i], _qts[i]);
            payable(_ownerIds[i]).transfer(_costs[i]);
        }
    
        emit ProductAdded(productCount, _name, _quantity, _price, _status);

        return productCount; // Return the newly created product ID
    }

    function changeProductStatus(uint256 productId, uint256 newStatus) external {
        products[productId].status = newStatus;
    }

    
    function changeProductQuantity(uint256 _productId, uint256 _qts) external {
        products[_productId].quantity -= _qts;
    }

    // function getProductQuantity(uint256 _productId) view  external  returns (uint256) {
    //     return products[_productId].quantity;
    // }

}
