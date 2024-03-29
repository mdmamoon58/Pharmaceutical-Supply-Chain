// SPDX-License-Identifier: MIT
// This contract provides a mechanism for an administrator to register entities with specific details.
// It allows others to retrieve the registration information based on the entity ID or the total count of registered entities
pragma solidity ^0.8.0;

contract EntityRegistration {                    
    struct Entity {                       // Structure entity with 4 fields
        string name;
        string entityType;
        bool manuallyAuthenticated;
        bytes32 hashedAadhar;
    }

    mapping(uint256 => Entity) public entities;            //Map Entity with uint 256 identifier
    uint256 public entityCount;

    address public administrator;

    constructor() {
        administrator = msg.sender;         //initializes the administrator variable with the address of the deployed contract
    } 

    modifier onlyAdministrator() {                 //modifier restricts access to functions to only the contract administrator.
        require(msg.sender == administrator, "Only the administrator can perform this action");
        _;
    }

      //The function ensures that the name, entity type, and Aadhar number are valid before proceeding
    function registerEntity(string memory _name, string memory _entityType, bool _manuallyAuthenticated, uint256 _aadharNumber) external onlyAdministrator {
        require(bytes(_name).length > 0, "Name should not be empty");
        require(bytes(_entityType).length > 0, "Entity type should not be empty");
        require(_aadharNumber > 0, "Invalid Aadhar number");

        //a new Entity struct is created with the provided registration details
        Entity memory newEntity;
        newEntity.name = _name;
        newEntity.entityType = _entityType;
        newEntity.manuallyAuthenticated = _manuallyAuthenticated;
        newEntity.hashedAadhar = generateKey(_aadharNumber); //hashedAadhar field is generated by calling the generateKey internal function.

        //The entityCount is incremented, and the new entity is stored in the entities mapping using the updated count as the key.
        entityCount++;
        entities[entityCount] = newEntity; 
    }

    //returns the hashed value of the Aadhar number
    function generateKey(uint256 _aadharNumber) internal pure returns (bytes32) {
        require(_aadharNumber > 0, "Invalid Aadhar number");
        bytes32 hashedAadhar = keccak256(abi.encodePacked(_aadharNumber));
        return hashedAadhar;
    }

    function getEntityCount() external view returns (uint256) {
        return entityCount;
    }

    function getEntity(uint256 _entityId) external view returns (string memory, string memory, bool, bytes32) {
        require(_entityId > 0 && _entityId <= entityCount, "Invalid entity ID");

        Entity memory entity = entities[_entityId];
        return (entity.name, entity.entityType, entity.manuallyAuthenticated, entity.hashedAadhar);
    }
}
