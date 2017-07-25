require 'bundler'
Bundler.setup(:default)

require 'merit'

require 'fever/producer'

require 'fever/activity'
require 'fever/calculator'
require 'fever/composite_producer'
require 'fever/consumer'
require 'fever/deferrable_activity'
require 'fever/reserve_producer'
require 'fever/buffering_producer'
require 'fever/version'

# Models the behaviour of heat processes (household heaters, heat buffers,
# etc) on a time-resolved basis.
module Fever
  FRAMES = 8760

  module_function

  # Public: Given an enumerable, wraps it within a Merit::Curve. If `enum` is
  # already a curve, it is returned as-is.
  #
  # enum - Anything which responds to `to_a`.
  #
  # Returns a Merit::Curve.
  def curve(enum)
    length = enum.length

    return enum.to_a.dup if length == FRAMES

    if length > FRAMES
      raise(
        ArgumentError,
        "Input curve has too many items (#{ enum.length }), " \
        "must not exceed #{ Fever::FRAMES }"
      )
    end

    enum.to_a + Array.new(FRAMES - enum.length, 0.0)
  end

  # Public: Creates a new empty Curve.
  #
  # Returns an Array.
  def empty_curve
    Array.new(FRAMES, 0.0)
  end
end
