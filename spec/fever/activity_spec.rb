require 'spec_helper'

RSpec.describe Fever::Activity do
  let(:producer) { Fever::Producer.new(1.5) }
  let(:activity) { Fever::Activity.new(producer) }

  context 'with supply of 1.5' do
    context 'with consumption 1.0' do
      let!(:result) { activity.request(0, 1.0) }

      it 'computes the energy used as 1.0' do
        expect(result).to eq(1.0)
      end

      it 'sets the producer output to 1.0' do
        expect(producer.output_at(0)).to eq(1.0)
      end

      it 'sets the activity demand to 1.0' do
        expect(activity.demand).to eq(1.0)
      end
    end

    describe 'with consumpion of 2.0' do
      let!(:result) { activity.request(0, 2.0) }

      it 'computes the energy used as 1.5' do
        expect(result).to eq(1.5)
      end

      it 'sets the producer output to 1.5' do
        expect(producer.output_at(0)).to eq(1.5)
      end

      it 'sets the activity demand to 2.0' do
        expect(activity.demand).to eq(2.0)
      end
    end
  end
end
