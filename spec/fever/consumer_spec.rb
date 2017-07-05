require 'spec_helper'

RSpec.describe Fever::Consumer do
  let(:demand_curve) { Merit::Curve.new([1.0, 2.0, 3.0, 4.0]) }
  let(:consumer)     { Fever::Consumer.new(demand_curve) }

  it 'has a demand curve' do
    expect(consumer.demand_curve).to eq(demand_curve)
  end

  describe '#demand_at' do
    it 'returns demand in frame 0' do
      expect(consumer.demand_at(0)).to eq(1.0)
    end

    it 'returns demand in frame 1' do
      expect(consumer.demand_at(1)).to eq(2.0)
    end
  end
end
