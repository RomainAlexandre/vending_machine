require 'vending_machine_logger'

class VendingMachine

  attr_reader :available_items, :available_change, :selected_item, :inserted_money

  def initialize(available_items:, available_change:)
    @available_items = available_items
    @available_change = available_change
    @selected_item = nil
    @inserted_money = 0
  end

  def select_item(item_id)
    if available_items[item_id] && available_items[item_id]['quantity'] > 0
      @selected_item = available_items[item_id].merge('id' => item_id)
      VendingMachineLogger.log_screen("#{selected_item['name']} selected. Please insert #{selected_item['price']} or more.")
    else
      VendingMachineLogger.log_screen("Item #{item_id} not available. Please select another item.")
    end
  end

  def insert_money(coin_value)
    if selected_item == nil
      VendingMachineLogger.log_change(coin_value => 1)
      VendingMachineLogger.log_screen("Select an item before inserting money.")
      return
    end

    @inserted_money += coin_value
    @available_change[coin_value] += 1

    if inserted_money >= selected_item['price']
      return_selected_item!
    else
      remaining_to_insert = (selected_item['price'] - inserted_money).round(2)
      VendingMachineLogger.log_screen("You have inserted #{inserted_money}. You are missing #{remaining_to_insert}.")
    end
  end

  def cancel
    reset_machine!
  end

  def refill_change(new_change)
    available_change.merge!(new_change) do |_, old_quantity, new_quantity|
      old_quantity + new_quantity
    end
  end

  def refill_items(new_items)
    available_items.merge!(new_items) do |_, old_item, new_item|
      updated_item = new_item
      updated_item['quantity'] += old_item['quantity']
      updated_item
    end
  end

  private

  def return_selected_item!
    VendingMachineLogger.log_item_drop_area(selected_item['name'])
    VendingMachineLogger.log_screen("Please pick up your item.")
    @available_items[selected_item['id']]['quantity'] -= 1
    @inserted_money = (inserted_money - selected_item['price']).round(2)
    reset_machine!
  end

  def reset_machine!
    return_change!
    @selected_item = nil
  end

  def return_change!
    if inserted_money > 0
      VendingMachineLogger.log_change(calculate_change!)
      VendingMachineLogger.log_screen("Please pick up your change.")
    end
  end

  def calculate_change!
    sorted_change = available_change.sort_by{ |coin_value, _| -coin_value }
    change = sorted_change.each_with_object({}) do |(coin_value, coin_quantity), change|
      number_of_coin_by_value = (inserted_money / coin_value).truncate
      quantity_of_coins_to_return = (coin_quantity - number_of_coin_by_value) >= 0 ? number_of_coin_by_value : coin_quantity
      if quantity_of_coins_to_return > 0
        @inserted_money = (inserted_money - coin_value * quantity_of_coins_to_return).round(2)
        change[coin_value] = quantity_of_coins_to_return
      end
    end
    if inserted_money > 0
      VendingMachineLogger.log_screen("Not enough change in the machine. Sorry you are going to loose #{inserted_money}")
      @inserted_money = 0
    end
    change
  end
end
