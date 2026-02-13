// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";     // to prevent "Double Spend" or "Recursive call" hacks
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract PayrollManager  is ReentrancyGuard, Ownable, AutomationCompatibleInterface {
    
    struct Employee {
        address walletAddress;
        uint256 salaryAmount;      // Amount per payment period
        uint256 paymentFrequency;  // In seconds (e.g., 30 days = 2592000)
        uint256 lastPaymentTime;
        uint256 totalEarned;       // Total earned
        uint256 totalWithdrawn;    // Total already withdrawn
        bool active;
    }

    mapping(address => Employee) public employees;  // employee address => Employee details
    address[] public employeeList;                   // Array to iterate over employees
    uint256 public totalFunds;                       // Total deposited by employer

    event FundsDeposited(address indexed employer, uint256 amount);
    event EmployeeAdded(address indexed employee, uint256 salary, uint256 frequency);
    event EmployeeRemoved(address indexed employee);
    event SalaryPaid(address indexed employee, uint256 amount);
    event SalaryWithdrawn(address indexed employee, uint256 amount);
    event FundsWithdrawn(address indexed employer, uint256 amount);

    constructor() Ownable(msg.sender) {}
    
    // DEPOSIT: Employer deposits funds to pay salaries
    function depositFunds() external payable onlyOwner {
        require(msg.value > 0, "Must deposit something");
        totalFunds += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    // ADD EMPLOYEE: Only employer can add employees
    function addEmployee(address _employee, uint256 _salaryAmount, uint256 _paymentFrequency) external onlyOwner {
        require(_employee != address(0), "Invalid employee address");
        require(_salaryAmount > 0, "Salary must be > 0");
        require(!employees[_employee].active, "Employee already exists");
        
        employees[_employee] = Employee({
            walletAddress: _employee,
            salaryAmount: _salaryAmount,
            paymentFrequency: _paymentFrequency,
            lastPaymentTime: block.timestamp,
            totalEarned: 0,
            totalWithdrawn: 0,
            active: true
        });
        
        employeeList.push(_employee);
        emit EmployeeAdded(_employee, _salaryAmount, _paymentFrequency);
    }

    // REMOVE EMPLOYEE: Deactivate an employee
    function removeEmployee(address _employee) external onlyOwner {
        require(employees[_employee].active, "Employee not active");
        employees[_employee].active = false;
        emit EmployeeRemoved(_employee);
    }

    // PROCESS PAYMENT: Calculate and record earned salary (doesn't transfer)
    function processSalaryPayment(address _employee) public onlyOwner nonReentrant {
        Employee storage emp = employees[_employee];
        
        require(emp.active, "Employee is not active");
        require(block.timestamp >= emp.lastPaymentTime + emp.paymentFrequency, "Too early for next payment");
        require(totalFunds >= emp.salaryAmount, "Insufficient funds in vault");

        totalFunds -= emp.salaryAmount;
        emp.totalEarned += emp.salaryAmount;
        emp.lastPaymentTime = block.timestamp;

        emit SalaryPaid(_employee, emp.salaryAmount);
    }

    // BATCH PAYMENT: Process all eligible employees at once
    function batchProcessPayments() external onlyOwner {
        for (uint256 i = 0; i < employeeList.length; i++) {
            address empAddress = employeeList[i];
            Employee storage emp = employees[empAddress];
            
            // Only process if active and payment is due
            if (emp.active && 
                block.timestamp >= emp.lastPaymentTime + emp.paymentFrequency &&
                totalFunds >= emp.salaryAmount) {
                
                totalFunds -= emp.salaryAmount;
                emp.totalEarned += emp.salaryAmount;
                emp.lastPaymentTime = block.timestamp;
                
                emit SalaryPaid(empAddress, emp.salaryAmount);
            }
        }
    }

    // ------------------------- CHAINLINK AUTOMATION -------------------------

    /**
     * @dev Chainlink Automation calls this to check if upkeep is needed
     * Returns true if any employee is due for payment
     */
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        // Check if any employee is due for payment and we have funds
        for (uint256 i = 0; i < employeeList.length; i++) {
            address empAddress = employeeList[i];
            Employee storage emp = employees[empAddress];
            
            if (emp.active && 
                block.timestamp >= emp.lastPaymentTime + emp.paymentFrequency &&
                totalFunds >= emp.salaryAmount) {
                upkeepNeeded = true;
                break;
            }
        }

        return (upkeepNeeded, "");
    }

    /**
     * @dev Chainlink Automation calls this when checkUpkeep returns true
     * This processes all eligible payments
     */
    function performUpkeep(bytes calldata /* performData */) external override {
        // Re-validate that upkeep is needed
        bool upkeepNeeded = false;
        
        for (uint256 i = 0; i < employeeList.length; i++) {
            address empAddress = employeeList[i];
            Employee storage emp = employees[empAddress];
            
            if (emp.active && 
                block.timestamp >= emp.lastPaymentTime + emp.paymentFrequency &&
                totalFunds >= emp.salaryAmount) {
                upkeepNeeded = true;
                break;
            }
        }
        
        require(upkeepNeeded, "No upkeep needed");
        
        // Process all eligible payments
        for (uint256 i = 0; i < employeeList.length; i++) {
            address empAddress = employeeList[i];
            Employee storage emp = employees[empAddress];
            
            if (emp.active && 
                block.timestamp >= emp.lastPaymentTime + emp.paymentFrequency &&
                totalFunds >= emp.salaryAmount) {
                
                totalFunds -= emp.salaryAmount;
                emp.totalEarned += emp.salaryAmount;
                emp.lastPaymentTime = block.timestamp;
                
                emit SalaryPaid(empAddress, emp.salaryAmount);
            }
        }
    }
}