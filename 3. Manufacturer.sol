// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Manufacturer {
    struct Product {               // Structure entity with 3 fields
        uint256 price;
        uint256 quantity;
        bool available;
    }

    mapping(string => Product) private products;        //The products mapping is used to associate product names with their respective Product struct.
    mapping(address => bool) private registeredManufacturers;

    uint256 public currentTemperature; // Variable to store the current temperature
    uint256 public currentHumidity; // Variable to store the current humidity
    uint256 public currentPressure; // Variable to store the current pressure
    uint256 public currentLight; // Variable to store the current light intensity

    modifier onlyRegisteredManufacturer() {      ////This modifier ensures that only registered manufacturers can call functions that have this modifier applied.
        require(registeredManufacturers[msg.sender], "Only registered Manufacturers can call this function");
        _;
    }

    event ProductPurchased(address buyer, string productName, uint256 price, uint256 quantity);
    event TemperatureRetrieved(uint256 timestamp, uint256 temperature);
    event HumidityRetrieved(uint256 timestamp, uint256 humidity);
    event PressureRetrieved(uint256 timestamp, uint256 pressure);
    event LightRetrieved(uint256 timestamp, uint256 light);

    function registerManufacturer() external {
        registeredManufacturers[msg.sender] = true;
    }

    function unregisterManufacturer() external {
        registeredManufacturers[msg.sender] = false;
    }

    function addProduct(string memory name, uint256 price, uint256 quantity) external onlyRegisteredManufacturer {
        require(!products[name].available, "Product already exists");

        Product memory newProduct = Product(price, quantity, true);
        products[name] = newProduct;
    }

    function removeProduct(string memory name) external onlyRegisteredManufacturer {
        require(products[name].available, "Product does not exist");

        delete products[name];
    }

    function isManufacturerRegistered(address manufacturer) external view returns (bool) {
        return registeredManufacturers[manufacturer];
    }

    function buyProduct(string memory name, uint256 quantityToBuy) external payable {
        require(products[name].available, "Product does not exist");
        require(msg.value >= products[name].price * quantityToBuy, "Insufficient funds");
        require(products[name].quantity >= quantityToBuy, "Not enough quantity available");

        // Perform the product purchase logic here

        // For simplicity, let's assume the Manufacturer is transferring the product directly to the manufacturer's address
        payable(msg.sender).transfer(msg.value);

        products[name].quantity -= quantityToBuy;

        emit ProductPurchased(msg.sender, name, products[name].price, products[name].quantity);
    }

    function getTemperature(uint256 timestamp) external {
        require(timestamp > 0, "Invalid timestamp");
        uint256 temperature = getRandomTemperature(); // Generate a random temperature between 0 and 50

        currentTemperature = temperature; // Store the current temperature

        emit TemperatureRetrieved(timestamp, temperature);
    }

    function getHumidity(uint256 timestamp) external {
        require(timestamp > 0, "Invalid timestamp");
        uint256 humidity = getRandomHumidity(); // Generate a random humidity value

        currentHumidity = humidity; // Store the current humidity

        emit HumidityRetrieved(timestamp, humidity);
    }

    function getPressure(uint256 timestamp) external {
        require(timestamp > 0, "Invalid timestamp");
        uint256 pressure = getRandomPressure(); // Generate a random pressure value

        currentPressure = pressure; // Store the current pressure

        emit PressureRetrieved(timestamp, pressure);
    }

    function getLight(uint256 timestamp) external {
        require(timestamp > 0, "Invalid timestamp");
        uint256 light = getRandomLight(); // Generate a random light intensity value

        currentLight = light; // Store the current light intensity

        emit LightRetrieved(timestamp, light);
    }

    //By using the current block's timestamp, previous random number, and block number as input for the hash function, 
    // the generated random number will be different for each block.  
    function getRandomTemperature() private view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.number)));
        return randomNumber % 51; // Generate a random number between 0 and 50
    }

    function getRandomHumidity() private view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.number)));
        return (randomNumber % 51) + 50; // Generate a random number between 50 and 100
    }

    function getRandomPressure() private view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.number)));
        return (randomNumber % 101) + 900; // Generate a random number between 900 and 1000
    }

    function getRandomLight() private view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.number)));
        return randomNumber % 1001; // Generate a random number between 0 and 1000
    }
}