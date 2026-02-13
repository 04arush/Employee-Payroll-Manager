// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/EmployeeSalaryManager.sol";

contract DeployPayroll is Script {
    function run() external {
        // Get private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the contract
        PayrollManager payroll = new PayrollManager();
        
        console.log("PayrollManager deployed to:", address(payroll));
        console.log("Owner (Employer):", payroll.owner());
        
        vm.stopBroadcast();
    }
}