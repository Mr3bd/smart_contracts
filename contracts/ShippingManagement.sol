// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./OrderManagement.sol";

interface OrderManagementInterface {
    function changeOrderStatus(uint256 orderId, uint256 newStatus) external;
}


contract ShippingManagement {
    struct ShippingRequest {
        uint256 id;
        uint256 orderId;
        uint256 status; // 1: Pending, 2: In Progress, 3: Completed, 4: Canceled
        address lgUser;
        uint256 reward;
        uint256 country;
        uint256 city;
        uint256 streen;
        uint256 zipcode;
        uint256 building;
    }

    mapping(uint256 => ShippingRequest) public shippingRequests;
    uint256 public requestCount;

    OrderManagementInterface public orderContract;
    
    event ShippingRequestAdded(uint256 indexed reqId, uint256 orderId, uint256 status, address lgUser, uint256 reward, uint256 country, uint256 city, uint256 street, uint256 zipcode, uint256 building);
    event ShippingRequestStatusChanged(uint256 indexed reqId, uint256 status);
    event RewardTransferred(uint256 indexed reqId, address indexed receiver, uint256 amount);

    constructor(address _orderContractAddress) {
        orderContract = OrderManagementInterface(_orderContractAddress);
    }


    function addShippingRequest(uint256 _orderId, uint256 _reward, uint256 _country, uint256 _city, uint256 _street, uint256 _zipcode, uint256 _building) external payable returns (uint256) {
        require(msg.value == _reward, "Incorrect reward amount sent");
        requestCount++;
        shippingRequests[requestCount] = ShippingRequest(requestCount, _orderId, 1, address(0), _reward, _country, _city, _street, _zipcode, _building);
        emit ShippingRequestAdded(requestCount, _orderId, 1, address(0), _reward, _country, _city,  _street,  _zipcode,  _building);
        return requestCount;
    }


    function acceptShippingRequest(uint256 _id, address _lgUser) external{
        require(shippingRequests[_id].lgUser == address(0), "Request already accepted");
        
        shippingRequests[_id].lgUser = _lgUser;
        shippingRequests[_id].status = 2;
        uint256 x = shippingRequests[_id].orderId;
        orderContract.changeOrderStatus(x, 6);
        emit ShippingRequestStatusChanged(_id, 2);
    }

    function completeShippingRequest(uint256 _id) external payable  {
        uint256 reward = shippingRequests[_id].reward;

        shippingRequests[_id].status = 3;

        uint256 x = shippingRequests[_id].orderId;
        orderContract.changeOrderStatus(x, 7);

        // Transfer reward to Logistic user
        payable(msg.sender).transfer(reward);

        emit RewardTransferred(_id, msg.sender, reward);
        emit ShippingRequestStatusChanged(_id, 3);
    }

    function cancelshippingRequest(uint256 _id) external payable  {
        uint256 reward = shippingRequests[_id].reward;
        shippingRequests[_id].status = 4;

        uint256 x = shippingRequests[_id].orderId;
        orderContract.changeOrderStatus(x, 11);

        payable(msg.sender).transfer(reward);

        emit ShippingRequestStatusChanged(_id, 4);
    }

}
