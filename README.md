# Employee Payroll Manager

A decentralized payroll management system built with Solidity smart contracts, leveraging Chainlink Automation for automated salary payments. This project enables employers to manage employee salaries on-chain with automated, time-based payment processing.

## Features

- **Automated Salary Payments**: Chainlink Automation triggers salary payments based on configurable payment frequencies
- **Flexible Payment Schedules**: Set custom payment frequencies for each employee (daily, weekly, monthly, etc.)
- **Secure Fund Management**: Employer deposits funds into the contract vault for salary distribution
- **Employee Management**: Add, remove, and manage employee records on-chain
- **Batch Processing**: Process multiple employee payments in a single transaction
- **Reentrancy Protection**: Built with OpenZeppelin's ReentrancyGuard for security
- **Access Control**: Owner-only functions for employer operations

## Tech Stack

- **Solidity ^0.8.19**: Smart contract development
- **Foundry**: Development framework and testing
- **Chainlink Automation**: Automated payment execution
- **OpenZeppelin**: Security and access control libraries

## Smart Contract Architecture

### PayrollManager Contract

The main contract includes:

- **Employee Struct**: Stores employee details (address, salary, frequency, payment history)
- **Fund Management**: Deposit and withdraw functions for the employer
- **Employee Operations**: Add/remove employees with custom salary configurations
- **Payment Processing**: Manual and automated salary payment functions
- **Chainlink Integration**: `checkUpkeep` and `performUpkeep` for automation

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/downloads)
- An Ethereum wallet with testnet ETH (Sepolia)
- [Chainlink](https://automation.chain.link/) account (for automated payments)
- [Alchemy](https://www.alchemy.com/) account (for Sepolia RPC URL)
- [Etherscan](https://etherscan.io/apidashboard) account (for Etherscan API key)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/04arush/Employee-Payroll-Manager.git
cd Employee-Payroll-Manager
```

2. Install dependencies:
```bash
forge install
```

3. Create a `.env` file:
```bash
PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=your_sepolia_rpc_url
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## Usage

### Build

```bash
forge build
```

### Test

```bash
forge test
```

### Deploy

Deploy to Sepolia testnet:
```bash
forge script script/DeployPayroll.s.sol:DeployPayroll --rpc-url sepolia --broadcast --verify
```

### Contract Interaction

After deployment, interact with the contract:

1. **Deposit Funds** (Employer):
```bash
cast send <CONTRACT_ADDRESS> "depositFunds()" --value 10ether --private-key <PRIVATE_KEY> --rpc-url sepolia
```

2. **Add Employee**:
```bash
cast send <CONTRACT_ADDRESS> "addEmployee(address,uint256,uint256)" <EMPLOYEE_ADDRESS> <SALARY_AMOUNT> <PAYMENT_FREQUENCY> --private-key <PRIVATE_KEY> --rpc-url sepolia
```

Example: Pay 1 ETH (00000000000000000 Wei) every 30 days (2592000 seconds)
```bash
cast send <CONTRACT_ADDRESS> "addEmployee(address,uint256,uint256)" 0x123... 1000000000000000000 2592000 --private-key <PRIVATE_KEY> --rpc-url sepolia
```

3. **Check Employee Details**:
```bash
cast call <CONTRACT_ADDRESS> "employees(address)" <EMPLOYEE_ADDRESS> --rpc-url sepolia
```

4. **Manual Batch Payment**:
```bash
cast send <CONTRACT_ADDRESS> "batchProcessPayments()" --private-key <PRIVATE_KEY> --rpc-url sepolia
```

## Chainlink Automation Setup

1. Visit [Chainlink Automation](https://automation.chain.link/)
2. Connect your wallet and select Sepolia network
3. Register a new Upkeep:
   - **Target Contract**: Your deployed PayrollManager address
   - **Upkeep Name**: Employee Payroll Automation
   - **Gas Limit**: 500,000 (adjust based on employee count)
   - **Starting Balance**: Fund with LINK tokens (use [Chainlink Faucets](https://faucets.chain.link/) for Sepolia LINK)
4. The automation will automatically call `performUpkeep` when employees are due for payment

! Note: Setting up Chainlink Automation does cost more Wei.

## Contract Functions

### Employer Functions (onlyOwner)
- `depositFunds()`: Deposit ETH into the contract
- `addEmployee(address, uint256, uint256)`: Add new employee with salary and frequency
- `removeEmployee(address)`: Deactivate an employee
- `processSalaryPayment(address)`: Manually process single employee payment
- `batchProcessPayments()`: Process all eligible employee payments

### Chainlink Automation Functions
- `checkUpkeep(bytes)`: Checks if any employee is due for payment
- `performUpkeep(bytes)`: Executes payments for all eligible employees

### View Functions
- `employees(address)`: Get employee details
- `employeeList(uint256)`: Get employee address by index
- `totalFunds()`: View total funds in contract

## Security Features

- **ReentrancyGuard**: Prevents reentrancy attacks
- **Ownable**: Access control for employer-only functions
- **Input Validation**: Checks for valid addresses and amounts
- **Fund Verification**: Ensures sufficient funds before processing payments

## Project Structure

```
employee-salary-manager/
├── src/
│   └── EmployeeSalaryManager.sol     # Main payroll contract
├── script/
│   └── DeployPayroll.s.sol           # Deployment script
├── test/                             # Test files
├── broadcast/DeployPayroll.s.sol/11155111      # Broadcast files
│   ├── run-1770966698297.json
│   └── run-latest.json
├── lib/                              # Dependencies
│   ├── forge-std/
│   ├── openzeppelin-contracts/
│   └── chainlink-brownie-contracts/
├── .env                              # Store Private & API keys 
├── .gitignore
├── .gitmodules
├── foundry.lock
├── foundry.toml                      # Foundry configuration
├── LICENSE.md
└── README.md
```

## Dependencies

- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Chainlink Brownie Contracts](https://github.com/smartcontractkit/chainlink-brownie-contracts)
- [Forge Standard Library](https://github.com/foundry-rs/forge-std)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Support

For questions or issues, please open an issue on GitHub.