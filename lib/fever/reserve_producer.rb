module Fever
  # A producer which wraps around a Reserve, making available excess energy
  # stored in prior frames.
  class ReserveProducer < Producer
    attr_reader :reserve

    def initialize(capacity, reserve, input_capacity: Float::INFINITY, **kwargs)
      super(capacity, **kwargs)
      @reserve = reserve
      @input_capacity = input_capacity
    end

    # Public: Adds an amount of energy to the reserve.
    #
    # It is assumes that this is called only once per-frame, therefore does not
    # guard against exceeding the input capacity with multiple calls in one
    # frame.
    #
    # Returns the actual amount of energy used; may be less depending on
    # capacity and availability of the reserve.
    def store_excess(frame, amount)
      amount = @input_capacity if amount > @input_capacity
      converted = amount * @input_efficiency[frame]

      added = @reserve.add(frame, converted)
      @output_curve[frame] -= added

      added / @input_efficiency[frame]
    end

    def source_at(frame)
      return 0.0 if @output_curve[frame] > 0
      @output_curve[frame].abs / @input_efficiency[frame]
    end

    def request(frame, amount)
      available = @reserve.at(frame)
      amount    = available if amount > available

      @reserve.take(frame, super(frame, amount))
    end
  end
end
