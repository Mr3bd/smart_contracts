// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MaterialManagement {
    struct Material {
        string name;
        uint256 quantity;
        uint256 price; 
    }

    mapping(uint256 => Material) public materials;
    uint256 public materialCount;

    event MaterialAdded(uint256 indexed materialId, string name, uint256 quantity, uint256 price);
    event QuantityUpdated(uint256 indexed materialId, uint256 quantity);

    function addMaterial(string memory _name, uint256 _quantity, uint256 _price) external returns (uint256) {
        materialCount++;
        materials[materialCount] = Material(_name, _quantity, _price);
        emit MaterialAdded(materialCount, _name, _quantity, _price);

        return materialCount;
    }

    function setQuantity(uint256  _materialId,  uint256 _qts)  public  {
        materials[_materialId] = Material(materials[_materialId].name, materials[_materialId].quantity-_qts, materials[_materialId].price);
        emit QuantityUpdated(_materialId, materials[_materialId].quantity);
    }
}
