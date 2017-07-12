module Fever
  # Given a collection of consumers and activities, determines how much energy
  # is to be produced, and by what.
  class Calculator
    attr_reader :consumer
    attr_reader :activities

    # Public: Creates a new Calculator.
    #
    # consumer -   The consumer which represents total demand for energy
    #              throughout the year.
    # activities - An array of activities, which will be responsible for
    #              fulfilling demand.
    #
    # Returns a calculator.
    def initialize(consumer, activities)
      @consumer   = consumer
      @activities = activities

      @storage = activities.map(&:producer).select do |prod|
        prod.respond_to?(:store_excess)
      end
    end

    # Public: Calculates demand and supply for a single frame.
    #
    # Returns nothing.
    def calculate_frame(frame)
      demand = @consumer.demand_at(frame)

      @activities.each do |activity|
        @consumer.receive(
          frame,
          activity.request(frame, demand * activity.share)
        )
      end
    end

    # Public: Stores excess energy.
    #
    # Returns nothing.
    def store_excess(frame, amount)
      return 0.0 if amount.zero?

      @storage.each do |prod|
        amount -= prod.store_excess(frame, amount)
      end
    end
  end
end
