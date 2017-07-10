require 'bundler'
Bundler.setup(:default)

require 'merit'

require 'fever/activity'
require 'fever/calculator'
require 'fever/consumer'
require 'fever/deferrable_activity'
require 'fever/producer'
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
    enum.is_a?(Merit::Curve) ? enum : Merit::Curve.new(enum.to_a)
  end

  # Public: Creates a new empty Curve.
  #
  # Returns a Merit::Curve.
  def empty_curve
    Merit::Curve.new([], FRAMES)
  end
end
