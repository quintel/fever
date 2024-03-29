module Fever
  # Activity represents a combination of consumption and production of energy
  # for one type of technology.
  class Activity
    attr_reader :producer
    attr_reader :share
    attr_reader :demand
    attr_reader :demand_curve
    attr_reader :production_curve

    # Creates a new Activity wrapping the given producer, with an optional
    # share.
    def initialize(producer, share: 1.0)
      @producer = producer
      @share    = share
      @demand   = 0.0
      @demand_curve = Fever.empty_curve
      @production_curve = Fever.empty_curve
    end

    # Public: Calculates the activity in the chosen frame.
    #
    # Returns the amount of energy used.
    def request(frame, amount)
      @demand += amount
      @demand_curve[frame] += amount

      used = @producer.request(frame, amount)
      @production_curve[frame] += used

      used
    end

    def inspect
      "#<#{ self.class.name } producer=#{ @producer } share=#{ @share }>"
    end

    def to_s
      "#{ self.class.name }(#{ @producer } @ #{ @share })"
    end
  end
end
