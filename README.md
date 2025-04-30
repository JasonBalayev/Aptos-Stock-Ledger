# Stock Tracker - Aptos Move Module

This repository contains a simple stock tracking application built on the Aptos blockchain using the Move programming language. It allows users to track stock symbols, names, and prices on-chain.

## Features

- Initialize a personal stock tracker
- Add stocks with symbol, name, and price
- Update stock prices
- View stock details and prices
- Event tracking for stock additions and price updates

## Prerequisites

- [Aptos CLI](https://aptos.dev/cli-tools/aptos-cli-tool/install-aptos-cli)
- [Git](https://git-scm.com/downloads)
- [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell) (for Windows) or Terminal (for macOS/Linux)

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/stock-tracker.git
   cd stock-tracker
   ```

2. Start a local Aptos testnet:
   ```
   aptos node run-local-testnet --with-faucet --force-restart
   ```
   Keep this terminal window open while working with the application.

3. In a new terminal window, initialize your Aptos account:
   ```
   aptos init
   ```
   - Select `local` as the network
   - Press Enter to generate a new key

4. Publish the module:
   ```
   aptos move publish --named-addresses stock_tracker=default
   ```
   - Confirm the transaction when prompted

## Usage

### Initialize Your Stock Tracker

Before adding stocks, you need to initialize your stock tracker:

```aptos move run --function-id default::stock_tracker::initialize
```

### Add Stocks

Add stocks to your tracker with symbol, name, and price (in cents):

```
aptos move run --function-id default::stock_tracker::add_stock --args string:AAPL string:"Apple Inc." u64:17500
aptos move run --function-id default::stock_tracker::add_stock --args string:MSFT string:"Microsoft Corporation" u64:33000
aptos move run --function-id default::stock_tracker::add_stock --args string:GOOGL string:"Alphabet Inc." u64:14000
```

### Update Stock Prices

Update stock prices as they change:

```
aptos move run --function-id default::stock_tracker::update_price --args string:AAPL u64:18000
```

### View Stock Information

To view stock details, you'll need your account address:

```
aptos account list
```

Copy your account address and use it to view stock details:

```
aptos move view --function-id default::stock_tracker::get_stock_details --args address:YOUR_ADDRESS string:AAPL
```

To view just the price:

```
aptos move view --function-id default::stock_tracker::get_stock_price --args address:YOUR_ADDRESS string:AAPL
```

## Project Structure

- `sources/stock_tracker.move`: The main Move module containing the stock tracking logic
- `Move.toml`: Package configuration file for the Move module
- `.aptos/`: Configuration directory for Aptos CLI
- `.gitignore`: Git ignore file

## Understanding the Code

### Stock Structure

```move
struct Stock has store, drop, copy {
    symbol: String,
    name: String,
    price: u64,   
    last_updated: u64,   
}
```

This structure represents a stock with its symbol, company name, price (in cents), and last updated timestamp.

### StockTracker Resource

```move
struct StockTracker has key {
    stocks: Table<String, Stock>,
    add_stock_events: event::EventHandle<AddStockEvent>,
    update_price_events: event::EventHandle<UpdatePriceEvent>,
}
```

This resource is stored in the user's account and contains a table of stocks and event handles for tracking changes.

### Main Functions

- `initialize`: Creates the StockTracker resource in the user's account
- `add_stock`: Adds a new stock to the tracker
- `update_price`: Updates the price of an existing stock
- `get_stock_price`: Returns the price of a stock
- `get_stock_details`: Returns all details of a stock

## Extending the Project

Here are some ideas for extending this project:

1. Add portfolio tracking to track owned stocks and quantities
2. Implement historical price tracking
3. Create a simple web frontend using React
4. Connect to real stock data APIs for automatic price updates
5. Add user permissions for collaborative stock tracking

### Contributing

Feel free to contribute to this project by submitting issues or pull requests!
