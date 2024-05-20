// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProductManagement.sol";

interface ProductManagementInterface {
    function changeProductStatus(uint256 productId, uint256 newStatus) external;
}
contract OrderManagement {

    struct Order {
        uint256 productId;
        uint256 quantity;
        uint256 status;
        uint256 cost;
    }

    mapping(uint256 => Order) public orders;
    uint256 public orderCount;
  

    ProductManagementInterface public productContract;

    event OrderAdded(uint256 indexed orderId, uint256 productId, uint256 quantity, uint256 status);


    constructor(address _productContractAddress) {
        productContract = ProductManagementInterface(_productContractAddress);
    }


    function addOrder(uint256 _productId, uint256 _quantity, uint256 _status, uint256 _cost, address _ownerUser, uint256 _pq) external payable returns (uint256) {
       uint256 diff = _pq - _quantity;
       bool enough = diff >= 0;

       require(enough,"Error, no enough quantity");
       
       if(diff == 0){
        productContract.changeProductStatus(_productId, 2);
       }
       orderCount++;

       payable(_ownerUser).transfer(_cost);
       
       emit OrderAdded(orderCount, _productId, _quantity, _status);

       return orderCount;
    }

    function changeOrderStatus(uint256 orderId, uint256 newStatus) external {
        orders[orderId].status = newStatus;
    }

}
