module Fever
  # An activity where unfulfilled demand will be deferred, to be attempted again
  # later.
  #
  # Notes:
  #
  #   * **This class is not thread-safe.**
  #
  #   * Presence of items in the deferments array is done with @deferments[0]
  #     rather than #any? or #none? since it's 3-4x faster.
  #
  class DeferrableActivity < Activity
    # Stores deferred energy (deficits) and the frame in which is expires.
    Deferment = Struct.new(:amount, :expire_at)

    # Public: Creates a new DeferrableActivity.
    #
    # expire_after - The maximum number of frames for which a deficit may be
    #                defered, after which no futher attempts will be made to
    #                fulfil.
    #
    # Returns a DeferrableActivity.
    def initialize(*args, expire_after: 4, **kwargs)
      super(*args, **kwargs)
      @deferments = []
      @expire_after = expire_after
    end

    def request(frame, amount)
      orig_demand = @demand

      # Drop expired deferments.
      @deferments.reject! { |df| df.expire_at < frame }

      produced = super(frame, amount + outstanding_demand)
      available = produced - fulfil_deferments(produced)

      # Set the new total demand on this node. This needs to be done because
      # the above call to super() will have incorrectly included deferred
      # demand which is already included in the figure for prior hours.
      @demand = orig_demand + amount

      if available < amount
        @deferments.push(
          Deferment.new(amount - available, frame + @expire_after)
        )
      end

      produced
    end

    private

    # Internal: Determines how much additional energy may be demanded in a
    # frame from previous deficits.
    #
    # Returns a numeric.
    def outstanding_demand
      return 0.0 unless @deferments[0]
      @deferments.sum(0.0, &:amount)
    end

    # Internal: Given energy, attempts to fulfil deferred demand stored in
    # deferments.
    #
    # Removes deferments whose demand is entirely fulfiled. Adjusts demand of
    # any which could only be partially fulfiled.
    #
    # Returns the amount of energy assigned.
    def fulfil_deferments(amount)
      return 0.0 if !@deferments[0] || amount.zero?

      remaining = amount
      fulfiled_count = 0

      @deferments.each do |deferment|
        if deferment.amount <= remaining
          remaining -= deferment.amount
          fulfiled_count += 1
        else
          deferment.amount -= remaining
          remaining = 0.0
          break
        end
      end

      # Remove the fulfiled deferments without creating a new array.
      fulfiled_count.times { @deferments.shift }

      amount - remaining
    end
  end
end
