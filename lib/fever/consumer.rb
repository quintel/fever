module Fever
  # A participant which will define energy to be consumed (which must be
  # produced by other participants).
  class Consumer
    attr_reader :demand_curve
    attr_reader :load_curve

    # Public: Creates a new Consumer whose demand is defined by `demand_curve`.
    #
    # demand_curve - A Merit::Curve which defines the energy required by the
    #                Consumer in each frame.
    #
    # Returns a Consumer.
    def initialize(demand_curve)
      @demand_curve = Fever.curve(demand_curve)
      @load_curve = Fever.empty_curve
    end

    # Public: Instructs the given `amount` has been provided to the consumer to
    # meet its demand.
    #
    # Returns the amount.
    def receive(frame, amount)
      @load_curve[frame] += amount
      amount
    end

    # Public: Returns the load in the requested `frame`.
    def load_at(frame)
      @load_curve[frame]
    end

    # Public: Returns the demand of the Consumer in `frame`.
    #
    # Returns a numeric.
    def demand_at(frame)
      @demand_curve[frame] - @load_curve[frame]
    end
  end
end
