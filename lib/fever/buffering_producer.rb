module Fever
  # Preemptively consumes energy and stores it in the buffer for future use.
  # Energy is taken preferentially from the buffer to meet demand, and then the
  # producer will run to satisfy any remaining.
  class BufferingProducer < ReserveProducer
    def initialize(*)
      super

      # Describes the input load (after efficiency) i.e., energy used to fill
      # the buffer, plus any more required to meet demand instantaneously.
      @input_curve = Fever.empty_curve
    end

    # Public: Describes the amount of energy consumed to fulfil instantaneous
    # demand and fill up the the reserve.
    #
    # Returns a numeric.
    def source_at(frame)
      @input_curve[frame] / @input_efficiency[frame]
    end

    # Public: Requests the amount of energy to be consumed. Will fill up the
    # internal reserve with any unused capacity.
    #
    # Returns the energy available for consumption.
    def request(frame, amount)
      @output_curve[frame] += taken = take_from_reserve(frame, amount)

      capacity = @capacity[frame]
      deficit = amount - taken
      instantaneous = 0.0

      # If demand exceeds the amount stored, run the heat pump...
      if deficit.positive?
        instantaneous = deficit > capacity ? capacity : deficit

        @output_curve[frame] += instantaneous
        @input_curve[frame] += instantaneous
      end

      # If there is still available capacity, run to fill up the buffer.
      if (remaining_cap = capacity - instantaneous).positive?
        @input_curve[frame] += @reserve.add(frame, remaining_cap)
      end

      taken + instantaneous
    end

    private

    # Internal: Takes from the reserve the desired amount of energy.
    #
    # Ignored output capacity, since energy stored in the reserve was already
    # subject to the capacity constraint when it was added.
    #
    # Returns the energy taken; may be less than desired if the reserve has
    # insufficient stored.
    def take_from_reserve(frame, amount)
      available = @reserve.at(frame)
      amount    = available if amount > available

      @reserve.take(frame, amount)
    end
  end
end
