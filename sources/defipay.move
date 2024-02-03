/*
Disclaimer: Use of Unaudited Code for Educational Purposes Only
This code is provided strictly for educational purposes and has not undergone any formal security audit. 
It may contain errors, vulnerabilities, or other issues that could pose risks to the integrity of your system or data.

By using this code, you acknowledge and agree that:
    - No Warranty: The code is provided "as is" without any warranty of any kind, either express or implied. The entire risk as to the quality and performance of the code is with you.
    - Educational Use Only: This code is intended solely for educational and learning purposes. It is not intended for use in any mission-critical or production systems.
    - No Liability: In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the use or performance of this code.
    - Security Risks: The code may not have been tested for security vulnerabilities. It is your responsibility to conduct a thorough security review before using this code in any sensitive or production environment.
    - No Support: The authors of this code may not provide any support, assistance, or updates. You are using the code at your own risk and discretion.

Before using this code, it is recommended to consult with a qualified professional and perform a comprehensive security assessment. By proceeding to use this code, you agree to assume all associated risks and responsibilities.
*/

#[lint_allow(self_transfer)]
module defipay::defipay{

    // Imports
    // use std::debug;

    use sui::sui::SUI;
    use sui::tx_context::{TxContext, Self};
    use sui::coin::{Coin, Self};
    use sui::balance::{Self, Balance};
    use sui::transfer::{ transfer, share_object, public_transfer};
    use sui::object::{Self, UID};

    const FLOAT_SCALING: u64 = 1_000_000_000;

    // Errors
    const EInsufficientBalance: u64 = 0;
    const EDeniedAccess: u64 = 1;
    const ENotOwner: u64 = 2;

    struct Admin has key, store{
        id: UID,
        owner_address:address,
        balance: Balance<SUI>
    }

    struct Customer has key, store{
        id: UID,
        customer_address: address,
        flagged: bool,
        balance: Balance<SUI>,
        date: u64
    }

    fun init(ctx: &mut TxContext) {
        transfer(Admin{
            id: object::new(ctx),
            owner_address: tx_context::sender(ctx),
            balance: balance::zero()
        }, tx_context::sender(ctx));
    }

    public entry fun admin_address(admin: &Admin, ctx: &mut TxContext): address{
        //checks
        assert!(admin.owner_address == tx_context::sender(ctx), ENotOwner);
        admin.owner_address
    }

    public entry fun customer_address(customer: &Customer): address{
        customer.customer_address
    }

    public entry fun is_flagged(customer: &Customer): bool {
        customer.flagged
    }

    public fun create_customer(ctx: &mut TxContext, date: u64){
        //check that it is not admin address
       share_object(
            Customer{
                id: object::new(ctx),
                customer_address: tx_context::sender(ctx),
                flagged: false,
                balance: balance::zero(),
                date: date
            }
        )
    }

    // deposit function
    public fun deposit(
            admin: &mut Admin,
            customer: &mut Customer, 
            amount: &mut Coin<SUI>, 
            ctx: &mut TxContext)
    {
        //check that the person using this function is actually the customer
        assert!(customer.customer_address == tx_context::sender(ctx), ENotOwner);

        // let amount_balance = coin::into_balance(amount);
        let amount_balance_mut = coin::balance_mut(amount);
        let remaining_temp = balance::split(amount_balance_mut, FLOAT_SCALING);
        let remaining_temp_2 = balance::split(amount_balance_mut, FLOAT_SCALING);
        let remaining = balance::split(amount_balance_mut, FLOAT_SCALING);
        let _amount = coin::from_balance(remaining, ctx);

        public_transfer(_amount, admin.owner_address);

        balance::join(&mut customer.balance, remaining_temp);
        balance::join(&mut admin.balance, remaining_temp_2);

    }

    // withdraw function
    public fun withdraw (
        admin: &mut Admin,
        customer: &mut Customer,
        amount: Balance<SUI>,
        ctx: &mut TxContext
    ){
        //check if customer balance is greater or equal to amount being withdrawn
        assert!(balance::value(&amount)>balance::value(&customer.balance),EInsufficientBalance);

        //check that the person using this function is actually the customer
        assert!(customer.customer_address == tx_context::sender(ctx), ENotOwner);

        //check that customer is not admin
        assert!(customer.customer_address == admin.owner_address, EDeniedAccess);


        let amount__value = balance::value(&amount);
        let withdraw_coin = coin::from_balance(amount, ctx);
        public_transfer(withdraw_coin, tx_context::sender(ctx));

        let remaining = balance::split(&mut customer.balance, amount__value);
        let remaining_admin = balance::split(&mut admin.balance, amount__value);

        balance::join(&mut customer.balance, remaining);
        balance::join(&mut admin.balance, remaining_admin);           
           

    }

    // transfer function
    public fun pay_transfer(
        recipient_address: address,
        sender: &mut Customer,
        amount: &mut Coin<SUI>,
        ctx: &mut TxContext
    ){
        //check that it is the customer that has access to this function
        assert!(sender.customer_address == tx_context::sender(ctx), ENotOwner);
        //everyone has access to this function

        let amount_balance = coin::balance_mut(amount);
        let remaining_temp = balance::split(amount_balance, FLOAT_SCALING);
        let remaining = balance::split(amount_balance, FLOAT_SCALING);
        let _amount = coin::from_balance(remaining, ctx);

        public_transfer(_amount, recipient_address);

        balance::join(&mut sender.balance, remaining_temp);

    }

    //flag function (admin)

    public fun flag(
        admin: &Admin,
        customer: &mut Customer,
        ctx: &mut TxContext
    ){
        //only admin can operate this function
        assert!(admin.owner_address == tx_context::sender(ctx), EDeniedAccess);

        customer.flagged = !customer.flagged;
    }

}