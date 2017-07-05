module Fever
  # A participant which will define energy to be consumed (which must be
  # produced by other participants).
  class Consumer
    attr_reader :demand_curve

    # Public: Creates a new Consumer whose demand is defined by `demand_curve`.
    #
    # demand_curve - A Merit::Curve which defines the energy required by the
    #                Consumer in each frame.
    #
    # Returns a Consumer.
    def initialize(demand_curve)
      @demand_curve = Fever.curve(demand_curve)
    end

    # Public: Returns the demand of the Consumer in `frame`.
    #
    # Returns a numeric.
    def demand_at(frame)
      @demand_curve.get(frame)
    end
  end
end
