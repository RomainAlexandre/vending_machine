require 'yaml'

RSpec.describe VendingMachine do

  let(:initial_state) { YAML.load_file('./spec/fixtures/initial_state.yml') }
  let(:described_instance) { described_class.new(**initial_state) }

  describe '#select_item' do
    subject { described_instance.select_item(item_id) }

    context 'when item_id is invalid' do
      let(:item_id) { 1 }
      it do
        expect(VendingMachineLogger).to receive(:log_screen).with("Item #{item_id} not available. Please select another item.")
        expect{ subject }.to_not change { described_instance.selected_item }.from(nil)
      end
    end

    context 'when item_id is valid' do
      context 'when item quantity is zero' do
        let(:item_id) { 42 }
        it do
          expect(VendingMachineLogger).to receive(:log_screen).with("Item #{item_id} not available. Please select another item.")
          expect{ subject }.to_not change { described_instance.selected_item }.from(nil)
        end
      end

      context 'when item quantity is greater than zero' do
        let(:item_id) { 13 }
        it do
          expect(VendingMachineLogger).to receive(:log_screen).with("Kitkat selected. Please insert 2.59 or more.")
          expect{ subject }.to change { described_instance.selected_item }.from(nil).to("id" => 13, "name" => "Kitkat", "price" => 2.59, "quantity" => 15)
        end
      end
    end
  end

  describe '#insert_money' do
    subject { described_instance.insert_money(coin_value) }

    context 'when item is not selected is invalid' do
      let(:coin_value) { 2 }
      it do
        expect(VendingMachineLogger).to receive(:log_change).with(coin_value => 1)
        expect(VendingMachineLogger).to receive(:log_screen).with("Select an item before inserting money.")
        expect{ subject }.to_not change { described_instance.inserted_money }.from(0)
      end
    end

    context 'when item is selected' do
      let(:selected_item) { {"id" => 13, "name" => "Kitkat", "price" => 2.59, "quantity" => 15} }

      before do
        described_instance.instance_variable_set(:@selected_item, selected_item)
      end

      context 'when more money has been inserted and change is missing in the machine' do
        before do
          described_instance.instance_variable_set(:@inserted_money, 1)
        end

        let(:coin_value) { 2 }
        it do
          expect(VendingMachineLogger).to receive(:log_item_drop_area).with("Kitkat")
          expect(VendingMachineLogger).to receive(:log_screen).with("Please pick up your item.")
          expect(VendingMachineLogger).to receive(:log_screen).with("Not enough change in the machine. Sorry you are going to loose 0.01")
          expect(VendingMachineLogger).to receive(:log_change).with(0.2 => 2)
          expect(VendingMachineLogger).to receive(:log_screen).with("Please pick up your change.")
          subject
          expect(described_instance.selected_item).to eq(nil)
          expect(described_instance.inserted_money).to eq(0)
          expect(described_instance.available_items[13]['quantity']).to eq(14)
        end
      end

      context 'when not enough money has been inserted' do
        let(:coin_value) { 2 }
        it do
          expect(VendingMachineLogger).to receive(:log_screen).with("You have inserted 2. You are missing 0.59.")
          expect{ subject }.to change { described_instance.inserted_money }.from(0).to(2)
        end
      end

      context 'when the exact amount has been inserted' do
        before do
          described_instance.instance_variable_set(:@inserted_money, 2.58)
        end

        let(:coin_value) { 0.01 }
        it do
          expect(VendingMachineLogger).to receive(:log_item_drop_area).with("Kitkat")
          expect(VendingMachineLogger).to receive(:log_screen).with("Please pick up your item.")
          subject
          expect(described_instance.selected_item).to eq(nil)
          expect(described_instance.inserted_money).to eq(0)
          expect(described_instance.available_items[13]['quantity']).to eq(14)
        end
      end
    end
  end

  describe '#cancel' do
    subject { described_instance.cancel }

    context 'when machine was not used' do
      it { expect{ subject }.to_not change { described_instance.selected_item }.from(nil) }
      it { expect{ subject }.to_not change { described_instance.inserted_money }.from(0) }
    end

    context 'when an item was selected' do
      let(:selected_item) { {"id" => 13, "name" => "Kitkat", "price" => 2.59, "quantity" => 15} }

      before do
        described_instance.instance_variable_set(:@selected_item, selected_item)
      end

      context 'when money was inserted' do
        before do
          described_instance.instance_variable_set(:@inserted_money, 1)
        end

        it do
          expect(VendingMachineLogger).to receive(:log_change).with(1 => 1)
          expect(VendingMachineLogger).to receive(:log_screen).with("Please pick up your change.")
          expect{ subject }.to change { [described_instance.selected_item, described_instance.inserted_money] }.from([selected_item, 1]).to([nil, 0])
        end
      end

      context 'when money was not inserted' do
        it { expect{ subject }.to change { described_instance.selected_item }.from(selected_item).to(nil) }
        it { expect{ subject }.to_not change { described_instance.inserted_money }.from(0) }
      end
    end
  end

  describe '#refill_change' do
    subject { described_instance.refill_change(new_change) }

    let(:initial_change) do
      {
        2 => 5,
        1 => 10,
        0.5 => 20,
        0.2 => 25,
        0.1 => 30,
        0.05 => 35,
        0.02 => 40,
        0.01 => 0
      }
    end

    let(:new_change) { { 2 => 2, 0.01 => 5 } }

    let(:updated_change) do
      {
        2 => 7,
        1 => 10,
        0.5 => 20,
        0.2 => 25,
        0.1 => 30,
        0.05 => 35,
        0.02 => 40,
        0.01 => 5
      }
    end

    it do
      expect{ subject }.to change { described_instance.available_change }.from(initial_change).to(updated_change)
    end
  end

  describe '#refill_items' do
    subject { described_instance.refill_items(new_items) }

    let(:initial_items) do
      {
        13 => {
          "name" => "Kitkat",
          "price" => 2.59,
          "quantity" => 15
        },
        34 => {
          "name" => "Mars bar",
          "price" => 1.59,
          "quantity" => 10
        },
        36 => {
          "name" => "Twix",
          "price" => 2,
          "quantity" => 5
        },
        42 => {
          "name" => "Still water bottle",
          "price" => 3.55,
          "quantity" => 0
        }
      }
    end

    let(:new_items) do
      {
        13 => {
          "name" => "Kitkat",
          "price" => 3.50,
          "quantity" => 10
        },
        45 => {
          "name" => "Sparkling water bottle",
          "price" => 3.55,
          "quantity" => 10
        }
      }
    end

    let(:updated_items) do
      {
        13 => {
          "name" => "Kitkat",
          "price" => 3.50,
          "quantity" => 25
        },
        34 => {
          "name" => "Mars bar",
          "price" => 1.59,
          "quantity" => 10
        },
        36 => {
          "name" => "Twix",
          "price" => 2,
          "quantity" => 5
        },
        42 => {
          "name" => "Still water bottle",
          "price" => 3.55,
          "quantity" => 0
        },
        45 => {
          "name" => "Sparkling water bottle",
          "price" => 3.55,
          "quantity" => 10
        }
      }
    end

    it do
      expect{ subject }.to change { described_instance.available_items }.from(initial_items).to(updated_items)
    end
  end

end