# Vending Machine
[![Circle CI](https://circleci.com/gh/RomainAlexandre/vending_machine.svg?style=shield)](https://circleci.com/gh/RomainAlexandre/vending_machine.app)

A simple vending machine that performs as follow:
- Once an item is selected and the appropriate amount of money is inserted, the vending machine should return the correct product.
- It should also return change if too much money is provided, or ask for more money if insufficient funds have been inserted.
- The machine should take an initial load of products and change. The change will be of denominations 1p, 2p, 5p, 10p, 20p, 50p, £1, £2.
- There should be a way of reloading either products or change at a later point.
- The machine should keep track of the products and change that it contains.

The vending machine has three inputs:
- Coin inserter
- Pad to select items
- A button to cancel and retrieve inserted money

And three outputs:
- Screen that displays information to the user
- Item drop area
- Coin chute for any change

This application only represents the software of the vending machine and will use the standard I/O to display the three outputs.
See bellow, how to use the vending machine software in a console.

## Usage

### Installation:

Install ruby version 2.7.0 using your favorit version manager for ruby.

If using rvm, you just need to run
``` shell
rvm install "ruby-2.7.0"
```

Install bundler if not done already
``` shell
gem install bundler
```

Then install the gem for development and test
``` shell
bundle install
```

### Use Vending Machine
You can use the vending machine by calling
```shell
bin/console
```

Which will start a ruby shell with all the files you need to run the program and with a setup vending_machine. So you can then run in your ruby shell:
```ruby
require "yaml"

initial_state = YAML.load_file('./config/initial_state.yml')
vending_machine = VendingMachine.new(**initial_state)
vending_machine.select_iten(42)
vending_machine.insert_money(2)

# You can also create your own by passing these two keyword parameters
vending_machine = VendingMachine.new(
  available_items: {},
  available_change: {}
)
```

or you can run a small example:
```shell
bin/run_example
```

It will then display the following logs:
```ruby
I, [2020-03-25T22:40:54.369182 #89458]  INFO -- : ===== Displaying on screen =====
I, [2020-03-25T22:40:54.369249 #89458]  INFO -- : Mars bar selected. Please insert 1.59 or more.
I, [2020-03-25T22:40:54.369318 #89458]  INFO -- : ===== Displaying on screen =====
I, [2020-03-25T22:40:54.369330 #89458]  INFO -- : You have inserted 1. You are missing 0.59.
I, [2020-03-25T22:40:54.369343 #89458]  INFO -- : ===== Dropping in drop Area =====
I, [2020-03-25T22:40:54.369351 #89458]  INFO -- : Mars bar
I, [2020-03-25T22:40:54.369369 #89458]  INFO -- : ===== Displaying on screen =====
I, [2020-03-25T22:40:54.369378 #89458]  INFO -- : Please pick up your item.
I, [2020-03-25T22:40:54.369400 #89458]  INFO -- : ===== Dropping change in coins area =====
I, [2020-03-25T22:40:54.369413 #89458]  INFO -- : 0.2 x 2
I, [2020-03-25T22:40:54.369423 #89458]  INFO -- : 0.01 x 1
I, [2020-03-25T22:40:54.369433 #89458]  INFO -- : ===== Displaying on screen =====
I, [2020-03-25T22:40:54.369451 #89458]  INFO -- : Please pick up your change.
```

## Testing

Tests built using rspec, to run the suite do:

```shell
rspec spec/
```

## Improvements

Possible improvements for the future:
- Use a state machine
  - A vending machine follows a very precise state machine (Item selected, money inserted etc...). It will allow to simplify the code and if conditions present in the methods.
- Handle different currencies
  - The software for a vending machine should not care of which currency is used. The machine can only accept one currency (configured at the beginning) and should work the same way.
  - To achieve this we could create an actual object for money that will encapsulate the currency and the value. (It will also allow us to display the change as real coins and not decimal since each coin would be able to display itself correctly). Each different currency could inherrit from this base coin class to implement the specificity of the currency.
- Allow to buy multiple item at the same time by selecting more than one item.
  - This one should be quite straight forward. Allowing to select more items just increment the price the customer needs to pay to retrieve all items. Also change selected_item to be an array instead of a single value.
- Display change as real coins and not decimal
  - See handle differrent currencies.
- Authorization on actions as refill_items and refill_change
  - Use a secret key for these operation.
- Remember the inserted coins to be able to return exactly these ones if the customer cancel.
  - Change inserted_coins to be an array instead of a single value.
- Do not steal money from customer if missing change or at least made the user take the decision.
- Add validations on initialize parameters