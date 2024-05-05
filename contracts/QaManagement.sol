// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ProductManagement.sol";

interface ProductManagementInterface {
    function changeProductStatus(uint256 productId, uint256 newStatus) external;
}

contract QaManagement {
    struct QARequest {
        uint256 id;
        uint256 productId;
        uint256 status; // 1: Pending, 2: In Progress, 3: Completed, 4: Canceled
        address qaUser;
        uint256 reward;
    }

    mapping(uint256 => QARequest) public qaRequests;
    uint256 public requestCount;

    ProductManagementInterface public productContract;
    
    event QARequestAdded(uint256 indexed reqId, uint256 productId, uint256 status, address qaUser, uint256 reward);
    event QARequestStatusChanged(uint256 indexed reqId, uint256 status);
    event RewardTransferred(uint256 indexed reqId, address indexed receiver, uint256 amount);

    constructor(address _productContractAddress) {
        productContract = ProductManagementInterface(_productContractAddress);
    }


    function addQARequest(uint256 _productId, uint256 _reward) external payable returns (uint256) {
        require(msg.value == _reward, "Incorrect reward amount sent");
        requestCount++;
        qaRequests[requestCount] = QARequest(requestCount, _productId, 1, address(0), _reward);
        emit QARequestAdded(requestCount, _productId, 1, address(0), _reward);
        return requestCount;
    }


    function acceptQARequest(uint256 _id, address _qaUser) external{
        require(qaRequests[_id].qaUser == address(0), "Request already accepted");
        
        qaRequests[_id].qaUser = _qaUser;
        qaRequests[_id].status = 2;

        uint256 x = qaRequests[_id].productId;
        productContract.changeProductStatus(x, 8);

        emit QARequestStatusChanged(_id, 2);
    }

    function completeQARequest(uint256 _id, uint256 _status) external payable  {
        uint256 reward = qaRequests[_id].reward;

        qaRequests[_id].status = 3;

        // Change product status
        uint256 x = qaRequests[_id].productId;
        productContract.changeProductStatus(x, _status);

        // Transfer reward to QA user
        payable(msg.sender).transfer(reward);

        emit RewardTransferred(_id, msg.sender, reward);

        emit QARequestStatusChanged(_id, 3);
    }

    function cancelQARequest(uint256 _id) external payable  {
        uint256 reward = qaRequests[_id].reward;
        qaRequests[_id].status = 4;
        
        uint256 x = qaRequests[_id].productId;
        productContract.changeProductStatus(x, 4);

        payable(msg.sender).transfer(reward);

        emit QARequestStatusChanged(_id, 4);
    }

}
