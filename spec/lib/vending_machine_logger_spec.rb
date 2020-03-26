RSpec.describe VendingMachineLogger do
  describe '.log_screen' do
    subject { described_class.log_screen(message) }

    let(:message) { "My message is a test" }

    it do
      logger = double('logger')
      expect(VendingMachineLogger).to receive(:logger).exactly(2).times { logger }
      expect(logger).to receive(:info).with("===== Displaying on screen =====").once
      expect(logger).to receive(:info).with(message).once
      subject
    end
  end

  describe '.log_item_drop_area' do
    subject { described_class.log_item_drop_area(item) }

    let(:item) { "Twix" }

    it do
      logger = double('logger')
      expect(VendingMachineLogger).to receive(:logger).exactly(2).times { logger }
      expect(logger).to receive(:info).with("===== Dropping in drop Area =====").once
      expect(logger).to receive(:info).with(item).once
      subject
    end
  end

  describe '.log_change' do
    subject { described_class.log_change(change) }

    let(:change) { { 2 => 5, 0.02 => 3 } }

    it do
      logger = double('logger')
      expect(VendingMachineLogger).to receive(:logger).exactly(3).times { logger }
      expect(logger).to receive(:info).with("===== Dropping change in coins area =====").once
      expect(logger).to receive(:info).with("2 x 5").once
      expect(logger).to receive(:info).with("0.02 x 3").once
      subject
    end
  end
end