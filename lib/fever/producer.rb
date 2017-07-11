module Fever
  # A simple Producer who creates energy requested up to its maximum defined
  # capacity.
  class Producer
    # Public: Returns the capacity of the producer.
    attr_reader :capacity

    # Public: Returns the load curve of the producer.
    attr_reader :load_curve

    def initialize(capacity)
      @capacity = capacity
      @load_curve = Fever.empty_curve
    end

    # Public: Returns the load in the requested `frame`.
    def load_at(frame)
      @load_curve.get(frame)
    end

    # Public: Requests an `amount` of energy from the producer.
    #
    # If the producer has insufficient capacity to fulfil the request, the
    # amount produced may be lower than requested.
    #
    # Returns the amount of energy produced.
    def request(frame, amount)
      current_use = @load_curve.get(frame)
      available   = @capacity - current_use
      amount      = available if amount > available

      @load_curve.set(frame, current_use + amount)

      amount
    end
  end
end
