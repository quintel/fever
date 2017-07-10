require 'spec_helper'

RSpec.describe Fever::Calculator do
  let(:consumer)   { Fever::Consumer.new(Fever.curve([1.0, 2.0, 4.0])) }
  let(:producer)   { Fever::Producer.new(1.5) }
  let(:activity)   { Fever::Activity.new(producer) }
  let(:calculator) { Fever::Calculator.new(consumer, [activity]) }

  context 'with producer capacity 1.5' do
    context 'total demand of 1.0' do
      let!(:result) { calculator.calculate_frame(0) }

      it 'sets the consumer load to 1.0' do
        expect(consumer.load_curve.get(0)).to eq(1.0)
      end

      it 'sets the producer load to 1.0' do
        expect(producer.load_curve.get(0)).to eq(1.0)
      end
    end

    describe 'total demand of 2.0' do
      let!(:result) { calculator.calculate_frame(1) }

      it 'sets the consumer load to 1.5' do
        expect(consumer.load_curve.get(1)).to eq(1.5)
      end

      it 'sets the producer load to 1.5' do
        expect(producer.load_curve.get(1)).to eq(1.5)
      end
    end
  end # with producer capacity 1.5

  context 'with producer capacity 1.5, share 0.5' do
    let(:activity) { Fever::Activity.new(producer, share: 0.5) }

    context 'total demand of 1.0' do
      let!(:result) { calculator.calculate_frame(0) }

      it 'sets the consumer load to 0.5' do
        expect(consumer.load_curve.get(0)).to eq(0.5)
      end

      it 'sets the producer load to 0.5' do
        expect(producer.load_curve.get(0)).to eq(0.5)
      end
    end

    describe 'total demand of 2.0' do
      let!(:result) { calculator.calculate_frame(1) }

      it 'sets the consumer load to 1.0' do
        expect(consumer.load_curve.get(1)).to eq(1.0)
      end

      it 'sets the producer load to 1.0' do
        expect(producer.load_curve.get(1)).to eq(1.0)
      end
    end

    describe 'total demand of 4.0' do
      let!(:result) { calculator.calculate_frame(2) }

      it 'sets the consumer load to 1.5' do
        expect(consumer.load_curve.get(2)).to eq(1.5)
      end

      it 'sets the producer load to 1.5' do
        expect(producer.load_curve.get(2)).to eq(1.5)
      end
    end
  end # with producer capacity 1.5, share 0.5
end
