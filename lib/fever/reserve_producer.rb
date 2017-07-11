module Fever
  # A producer which wraps around a Reserve, making available excess energy
  # stored in prior frames.
  class ReserveProducer < Producer
    attr_reader :reserve

    def initialize(capacity, reserve)
      super(capacity)
      @reserve = reserve
    end

    def request(frame, amount)
      available = @reserve.at(frame)
      amount    = available if amount > available

      @reserve.take(frame, super(frame, amount))
    end
  end
end
