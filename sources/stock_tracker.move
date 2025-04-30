module stock_tracker::stock_tracker {
    use std::string::{String};
    use aptos_framework::account;
    use aptos_framework::event;
    use aptos_std::table::{Self, Table};
    use aptos_framework::timestamp;
    use std::signer;
    
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_STOCK_ALREADY_EXISTS: u64 = 2;
    const E_STOCK_DOES_NOT_EXIST: u64 = 3;
    
    struct Stock has store, drop, copy {
        symbol: String,
        name: String,
        price: u64,   
        last_updated: u64,   
    }
    
    struct StockTracker has key {
        stocks: Table<String, Stock>,
        add_stock_events: event::EventHandle<AddStockEvent>,
        update_price_events: event::EventHandle<UpdatePriceEvent>,
    }
 
    struct AddStockEvent has drop, store {
        symbol: String,
        name: String,
        price: u64,
        timestamp: u64,
    }
    
    struct UpdatePriceEvent has drop, store {
        symbol: String,
        old_price: u64,
        new_price: u64,
        timestamp: u64,
    }
    
    public entry fun initialize(account: &signer) {
        if (!exists<StockTracker>(signer::address_of(account))) {
            move_to(account, StockTracker {
                stocks: table::new(),
                add_stock_events: account::new_event_handle<AddStockEvent>(account),
                update_price_events: account::new_event_handle<UpdatePriceEvent>(account),
            });
        }
    }
 
    public entry fun add_stock(
        account: &signer,
        symbol: String,
        name: String,
        price: u64
    ) acquires StockTracker {
        let account_addr = signer::address_of(account);
        let stock_tracker = borrow_global_mut<StockTracker>(account_addr);
        assert!(!table::contains(&stock_tracker.stocks, symbol), E_STOCK_ALREADY_EXISTS);
        let current_time = timestamp::now_seconds();
        let stock = Stock {
            symbol: symbol,
            name: name,
            price: price,
            last_updated: current_time,
        };
        
        table::add(&mut stock_tracker.stocks, stock.symbol, stock);

        event::emit_event(&mut stock_tracker.add_stock_events, AddStockEvent {
            symbol: stock.symbol,
            name: stock.name,
            price: stock.price,
            timestamp: current_time,
        });
    }

    public entry fun update_price(
        account: &signer,
        symbol: String,
        new_price: u64
    ) acquires StockTracker {
        let account_addr = signer::address_of(account);
        let stock_tracker = borrow_global_mut<StockTracker>(account_addr);
        assert!(table::contains(&stock_tracker.stocks, symbol), E_STOCK_DOES_NOT_EXIST);
        let stock = table::borrow_mut(&mut stock_tracker.stocks, symbol);
        let old_price = stock.price;
        stock.price = new_price;
        stock.last_updated = timestamp::now_seconds();
        event::emit_event(&mut stock_tracker.update_price_events, UpdatePriceEvent {
            symbol: stock.symbol,
            old_price: old_price,
            new_price: new_price,
            timestamp: stock.last_updated,
        });
    }
 
    #[view]
    public fun get_stock_price(owner: address, symbol: String): u64 acquires StockTracker {
        let stock_tracker = borrow_global<StockTracker>(owner);
        assert!(table::contains(&stock_tracker.stocks, symbol), E_STOCK_DOES_NOT_EXIST);
        let stock = table::borrow(&stock_tracker.stocks, symbol);
        stock.price
    }
    
    #[view]
    public fun get_stock_details(owner: address, symbol: String): (String, String, u64, u64) acquires StockTracker {
        let stock_tracker = borrow_global<StockTracker>(owner);
        assert!(table::contains(&stock_tracker.stocks, symbol), E_STOCK_DOES_NOT_EXIST);
        let stock = table::borrow(&stock_tracker.stocks, symbol);
        (stock.symbol, stock.name, stock.price, stock.last_updated)
    }
} 