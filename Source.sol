// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Source is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant WARDEN_ROLE = keccak256("BRIDGE_WARDEN_ROLE");

    // Mapping to track approved tokens
    mapping(address => bool) public approved;
    // List of registered tokens
    address[] public tokens;

    // Events
    event Deposit(address indexed token, address indexed recipient, uint256 amount);
    event Withdrawal(address indexed token, address indexed recipient, uint256 amount);
    event Registration(address indexed token);

    constructor(address admin) {
        // Grant roles to the admin
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(WARDEN_ROLE, admin);
    }

    // Deposit tokens into the bridge contract
    function deposit(address _token, address _recipient, uint256 _amount) public {
        // Check if the token is registered
        require(approved[_token], "Token not registered");

        // Transfer tokens from sender to the contract
        bool success = ERC20(_token).transferFrom(msg.sender, address(this), _amount);
        require(success, "Token transfer failed");

        // Emit Deposit event
        emit Deposit(_token, _recipient, _amount);
    }

    // Withdraw tokens from the bridge contract
    function withdraw(address _token, address _recipient, uint256 _amount) public onlyRole(WARDEN_ROLE) {
        // Check if the token is registered
        require(approved[_token], "Token not registered");

        // Transfer tokens from the contract to the recipient
        bool success = ERC20(_token).transfer(_recipient, _amount);
        require(success, "Token transfer failed");

        // Emit Withdrawal event
        emit Withdrawal(_token, _recipient, _amount);
    }

    // Register a token to be bridged
    function registerToken(address _token) public onlyRole(ADMIN_ROLE) {
        // Check if the token is already registered
        require(!approved[_token], "Token already registered");

        // Approve the token
        approved[_token] = true;

        // Add token to the list
        tokens.push(_token);

        // Emit Registration event
        emit Registration(_token);
    }

    // Get the list of all registered tokens
    function getRegisteredTokens() public view returns (address[] memory) {
        return tokens;
    }
}
