module Fever
  # Activity represents a combination of consumption and production of energy
  # for one type of technology.
  class Activity
    attr_reader :consumer
    attr_reader :producer

    def initialize(consumer, producer)
      @consumer = consumer
      @producer = producer
    end

    # Public: Calculates the activity in the chosen frame.
    #
    # Returns the amount of energy used.
    def calculate(frame)
      @consumer.receive(
        frame,
        @producer.request(frame, @consumer.demand_at(frame))
      )
    end
  end
end
