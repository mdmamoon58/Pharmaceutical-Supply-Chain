// SPDX-License-Identifier: MIT
// this contract allows suppliers to register and add ingredients, 
// buyers to purchase ingredients, and provides functions to manage the state of suppliers and ingredients.
pragma solidity ^0.8.0;

contract IngredientSupplier {
    struct Ingredient {                      // Structure entity with 3 fields
        uint256 price;
        uint256 quantity;
        bool available;
    }

    mapping(string => Ingredient) private ingredients;      //The ingredients mapping is used to associate ingredient names with their respective Ingredient struct.
    mapping(address => bool) private registeredSuppliers;   //The registeredSuppliers mapping associates supplier addresses (address) with a boolean value. 

    modifier onlyRegisteredSupplier() {          //This modifier ensures that only registered suppliers can call functions that have this modifier applied.
        require(registeredSuppliers[msg.sender], "Only registered suppliers can call this function");
        _;
    }

    event IngredientPurchased(address buyer, string ingredientName, uint256 price, uint256 quantity);

    function registerSupplier() external { //This function allows any external account to register themselves as a supplier by calling it
        registeredSuppliers[msg.sender] = true;
    }

    function unregisterSupplier() external {
        registeredSuppliers[msg.sender] = false;
    }

    //This function allows only registered suppliers to add a new ingredient.
    function addIngredient(string memory name, uint256 price, uint256 quantity) external onlyRegisteredSupplier {
        require(!ingredients[name].available, "Ingredient already exists");

        Ingredient memory newIngredient = Ingredient(price, quantity, true);
        ingredients[name] = newIngredient;
    }

    function removeIngredient(string memory name) external onlyRegisteredSupplier {
        require(ingredients[name].available, "Ingredient does not exist");

        delete ingredients[name];
    }

    //This function allows anyone to check if a specific supplier is registered.
    function isSupplierRegistered(address supplier) external view returns (bool) {
        return registeredSuppliers[supplier];
    }

    //The function checks if the ingredient exists, if the buyer has sent enough funds to cover the purchase, and if there is sufficient quantity available.
    function buyIngredient(string memory name, uint256 quantityToBuy) external payable {
        require(ingredients[name].available, "Ingredient does not exist");
        require(msg.value >= ingredients[name].price * quantityToBuy, "Insufficient funds");
        require(ingredients[name].quantity >= quantityToBuy, "Not enough quantity available");

        // Perform the ingredient purchase logic here

        // For simplicity, let's assume the supplier is transferring the ingredient directly to the manufacturer's address
        payable(msg.sender).transfer(msg.value);

        ingredients[name].quantity -= quantityToBuy;

        emit IngredientPurchased(msg.sender, name, ingredients[name].price, ingredients[name].quantity);
    }
}
