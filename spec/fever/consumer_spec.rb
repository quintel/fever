require 'spec_helper'

RSpec.describe Fever::Consumer do
  let(:demand_curve) { Fever.curve([1.0, 2.0, 3.0, 4.0]) }
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

  describe '#receive' do
    context 'when the consumer has not yet received anything' do
      it 'returns the amount' do
        expect(consumer.receive(0, 2.0)).to eq(2.0)
      end

      it 'sets the amount consumed' do
        expect { consumer.receive(0, 2.0) }
          .to change { consumer.load_at(0) }.from(0).to(2)
      end

      it 'reduces demand' do
        expect { consumer.receive(0, 0.5) }
          .to change { consumer.demand_at(0) }.from(1.0).to(0.5)
      end
    end

    context 'when the consumer has received 1.0 already' do
      before { consumer.receive(0, 1.0) }

      it 'returns the amount' do
        expect(consumer.receive(0, 2.0)).to eq(2.0)
      end

      it 'sets the amount consumed' do
        expect { consumer.receive(0, 2.0) }
          .to change { consumer.load_at(0) }.from(1).to(3)
      end
    end
  end
end
