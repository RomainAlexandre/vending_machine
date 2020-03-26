require 'logger'

class VendingMachineLogger
  class << self
    def log_screen(message)
      logger.info("===== Displaying on screen =====")
      logger.info(message)
    end

    def log_item_drop_area(item)
      logger.info("===== Dropping in drop Area =====")
      logger.info(item)
    end

    def log_change(change)
      logger.info("===== Dropping change in coins area =====")
      change.each do |coin_value, coin_quantity|
        logger.info("#{coin_value} x #{coin_quantity}")
      end
    end

    private
    def logger
      @@logger ||= Logger.new(STDOUT)
    end
  end
end
