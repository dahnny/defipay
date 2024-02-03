# DefiPay

## Overview

DefiPay is a simple payment system that enables users deposit and also transfer funds to friends. It includes functionalities for managing administrators and customers, handling deposits, withdrawals, transfers, and flagging customers.

**Disclaimer: Use of Unaudited Code for Educational Purposes Only**

This code is provided strictly for educational purposes and has not undergone any formal security audit. It may contain errors, vulnerabilities, or other issues that could pose risks to the integrity of your system or data.

By using this code, you acknowledge and agree to the terms outlined in the disclaimer.

## Installation

To deploy and use the DefiPay smart contract, follow these steps:

1. **Move Compiler Installation:**
   Ensure you have the Move compiler installed. You can find the Move compiler and instructions on how to install it at [Sui Docs](https://docs.sui.io/).

2. **Compile the Smart Contract:**
   For this contract to compile successfully, please ensure you switch the dependencies to whichever you installed. 
`framework/devnet` for Devnet, `framework/testnet` for Testnet

   ```bash
   Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/devnet" }
   ```
then build the contract by running

```
sui move build
```
3. **Deployment:**
   Deploy the compiled smart contract to your blockchain platform of choice.

```
sui client publish --gas-budget 100000000 --json
```

## Functions

### `init`

- **Description:** Initializes the DefiPay smart contract by creating an admin account.

### `admin_address`

- **Description:** Retrieves the address of the admin.

### `customer_address`

- **Parameters:**
  - `customer: &Customer`

- **Description:** Retrieves the address of a customer.

### `is_flagged`

- **Parameters:**
  - `customer: &Customer`

- **Description:** Checks if a customer is flagged.

### `create_customer`

- **Parameters:**
  - `ctx: &mut TxContext`
  - `date: u64`

- **Description:** Creates a new customer account.

### `deposit`

- **Parameters:**
  - `admin: &mut Admin`
  - `customer: &mut Customer`
  - `amount: &mut Coin<SUI>`
  - `ctx: &mut TxContext`

- **Description:** Deposits funds into a customer's account.

### `withdraw`

- **Parameters:**
  - `admin: &mut Admin`
  - `customer: &mut Customer`
  - `amount: Balance<SUI>`
  - `ctx: &mut TxContext`

- **Description:** Withdraws funds from a customer's account.

### `pay_transfer`

- **Parameters:**
  - `recipient_address: address`
  - `sender: &mut Customer`
  - `amount: &mut Coin<SUI>`
  - `ctx: &mut TxContext`

- **Description:** Transfers funds from one customer to another.

### `flag`

- **Parameters:**
  - `admin: &Admin`
  - `customer: &mut Customer`
  - `ctx: &mut TxContext`

- **Description:** Flags or unflags a customer account.


## Security Considerations

- This code is provided for educational purposes only. It has not undergone a formal security audit, and there may be vulnerabilities.
- Before deploying in a production environment, conduct a thorough security review.

