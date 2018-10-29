module Fever
  # Given a collection of consumers and activities, determines how much energy
  # is to be produced, and by what.
  class Calculator
    attr_reader :consumer

    # Public: Creates a new Calculator.
    #
    # consumer -   The consumer which represents total demand for energy
    #              throughout the year.
    # activities - An array of activities, which will be responsible for
    #              fulfilling demand.
    #
    # Returns a calculator.
    def initialize(consumer, activities)
      activities = [activities] unless activities.first.is_a?(Array)

      @consumer = consumer
      @grouped_activities = activities

      @storage = self.activities.map(&:producer).select do |prod|
        prod.respond_to?(:store_excess)
      end
    end

    # Public: All activities participating in the calcualtion.
    #
    # Returns an array of Fever::Activity.
    def activities
      @grouped_activities.flatten
    end

    # Public: Calculates demand and supply for a single frame.
    #
    # Returns nothing.
    def calculate_frame(frame)
      demand = @consumer.demand_at(frame)

      @grouped_activities.each do |activities|
        assigned = 0.0

        activities.each do |activity|
          assigned += @consumer.receive(
            frame,
            activity.request(frame, demand * activity.share)
          )
        end

        demand -= assigned
      end
    end

    # Public: Stores excess energy.
    #
    # Returns the amount stored.
    def store_excess(frame, amount)
      return 0.0 if amount.zero?

      remaining = amount

      @storage.each do |prod|
        remaining -= prod.store_excess(frame, remaining)
      end

      amount - remaining
    end
  end
end
