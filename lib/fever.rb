require 'fever/producer'

require 'fever/activity'
require 'fever/calculator'
require 'fever/composite_producer'
require 'fever/consumer'
require 'fever/deferrable_activity'
require 'fever/reserve_producer'
require 'fever/buffering_producer'
require 'fever/version'

require 'merit'

# Models the behaviour of heat processes (household heaters, heat buffers,
# etc) on a time-resolved basis.
module Fever
  FRAMES = 8760

  module_function

  # Public: Given an enumerable or numeric, creates a new curve using it as the
  # base value. If `enum` already looks like a curve, it is returned as-is.
  #
  # base - A numeric, or anything which responds to `to_a`.
  #
  # Returns a Merit::Curve.
  def curve(base)
    if base.respond_to?(:to_curve) && base.length == Fever::FRAMES
      return base.to_curve
    end

    case base
    when Numeric then curve_from_numeric(base)
    when Enumerable then curve_from_enum(base)
    else raise(ArgumentError, "cannot create a curve from #{ base.inspect }")
    end
  end

  # Public: Creates a new empty Curve.
  #
  # Returns an Array.
  def empty_curve
    Array.new(FRAMES, 0.0)
  end

  # Internal: Creates a new curve where every value is set to the given Numeric.
  #
  # Returns an Array.
  def curve_from_numeric(numeric)
    [numeric] * Fever::FRAMES
  end

  private_class_method :curve_from_numeric

  # Internal: Returns a new curve from the given enumerable. If it has too few
  # elements, the end of the curve will be padded with zeros.
  #
  # Returns an Array
  def curve_from_enum(enum)
    length = enum.length

    if length == FRAMES
      return enum.respond_to?(:to_curve) ? enum.to_curve : enum.to_a.dup
    end

    if length > FRAMES
      raise(
        ArgumentError,
        "Input curve has too many items (#{ enum.length }), " \
        "must not exceed #{ Fever::FRAMES }"
      )
    end

    enum.to_a + Array.new(FRAMES - enum.length, 0.0)
  end

  private_class_method :curve_from_enum
end
