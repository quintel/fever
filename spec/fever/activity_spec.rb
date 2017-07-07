require 'spec_helper'

RSpec.describe Fever::Activity do
  let(:consumer) { Fever::Consumer.new(Fever.curve([1.0, 2.0])) }
  let(:producer) { Fever::Producer.new(1.5) }
  let(:activity) { Fever::Activity.new(consumer, producer) }

  context 'with consumption 1.0, 2.0, ...' do
    context 'and supply of 1.5' do
      describe 'in frame 0' do
        let!(:result) { activity.calculate(0) }

        it 'computes the energy used as 1.0' do
          expect(result).to eq(1.0)
        end

        it 'sets the consumer load to 1.5' do
          expect(consumer.load_curve.get(0)).to eq(1.0)
        end

        it 'sets the producer load to 1.5' do
          expect(producer.load_curve.get(0)).to eq(1.0)
        end
      end

      describe 'in frame 1' do
        let!(:result) { activity.calculate(1) }

        it 'computes the energy used as 1.5' do
          expect(result).to eq(1.5)
        end

        it 'sets the consumer load to 1.5' do
          expect(consumer.load_curve.get(1)).to eq(1.5)
        end

        it 'sets the producer load to 1.5' do
          expect(producer.load_curve.get(1)).to eq(1.5)
        end
      end
    end
  end
end
