// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserManagement {
    struct User {
        address userAdd;
        string name;
        uint256 role;
    }

    mapping(uint256 => User) public users;
    uint256 public userCount;

    event UserAdded(address indexed userAdd, string name, uint256 role);

    function addUser(address _userAdd, string memory _name, uint256 _role) external  {
        userCount++;
        users[userCount] = User(_userAdd, _name, _role);
        emit UserAdded(_userAdd, _name, _role);
    }

}