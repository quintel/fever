module Fever
  # A producer which wraps one or more other producers, assigning requests
  # entirely to the first producer until its capacity is reached, then to the
  # second, and so on.
  #
  # The composite itself has no capacity limit, and is restricted only by the
  # capacity of its components.
  class CompositeProducer < Producer
    # Public: Creates a new CompositeProducer, wrapping the given components
    # (others Producers).
    def initialize(components)
      @components = components
      super(Float::INFINITY)
    end

    # Public: Requests an `amount` of energy from the producer.
    #
    # If the producer has insufficient capacity to fulfil the request, the
    # amount produced may be lower than requested.
    #
    # Returns the amount of energy produced.
    def request(frame, amount)
      # Use an accumulator and #each iterator; 25% faster than #reduce.
      assigned = 0.0

      @components.each do |comp|
        assigned += comp.request(frame, amount - assigned)
        break if assigned >= amount
      end

      @load_curve[frame] += assigned
      assigned
    end
  end
end
