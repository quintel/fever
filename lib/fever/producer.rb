module Fever
  # A simple Producer who creates energy requested up to its maximum defined
  # capacity.
  class Producer
    # Public: Returns the capacity of the producer.
    attr_reader :capacity

    # Public: Returns the load curve of the producer.
    attr_reader :output_curve

    def initialize(capacity, input_efficiency: 1.0)
      @capacity = Fever.curve(capacity)
      @output_curve = Fever.empty_curve
      @input_efficiency = Fever.curve(input_efficiency)
    end

    # Public: Returns the load in the requested `frame`.
    def output_at(frame)
      @output_curve[frame]
    end

    # Public: Based on the input efficiency of the producer, returns how much
    # energy will be demanded in order to meet the load.
    def input_at(frame)
      @output_curve[frame] / @input_efficiency[frame]
    end

    # Public: Requests an `amount` of energy from the producer.
    #
    # If the producer has insufficient capacity to fulfil the request, the
    # amount produced may be lower than requested.
    #
    # Returns the amount of energy produced.
    def request(frame, amount)
      current_use = @output_curve[frame]
      available   = @capacity[frame] - current_use
      amount      = available if amount > available

      @output_curve[frame] += amount

      amount
    end

    def inspect
      "#<#{ self }>"
    end

    def to_s
      self.class.name
    end
  end
end
