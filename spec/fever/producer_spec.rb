require 'spec_helper'

RSpec.describe Fever::Producer do
  context 'with a capacity of 5.0' do
    let(:producer) { Fever::Producer.new(5.0) }

    it 'has a capacity of 5' do
      expect(producer.capacity).to eq(5)
    end

    context 'requesting 3.0 in frame 0' do
      let!(:request) { producer.request(0, 3.0) }

      it 'returns 3.0' do
        expect(request).to eq(3)
      end

      it 'sets the load curve in frame 0 to 3.0' do
        expect(producer.load_curve.get(0)).to eq(3)
      end

      context 'when requesting another 1.0' do
        let!(:second_request) { producer.request(0, 1.0) }

        it 'returns 1.0' do
          expect(second_request).to eq(1)
        end

        it 'sets the load curve in frame 0 to 4.0' do
          expect(producer.load_curve.get(0)).to eq(4.0)
        end

        it 'permits a third request' do
          expect(producer.request(0, 1.0)).to eq(1)
        end
      end

      context 'when requesting another 2.0' do
        let!(:second_request) { producer.request(0, 2.0) }

        it 'returns 2.0' do
          expect(second_request).to eq(2)
        end

        it 'sets the load curve in frame 0 to 5.0' do
          expect(producer.load_curve.get(0)).to eq(5.0)
        end

        it 'permits no further requests' do
          expect(producer.request(0, 1.0)).to eq(0)
        end
      end

      context 'when requesting another 3.0' do
        let!(:second_request) { producer.request(0, 3.0) }

        it 'returns 2.0' do
          expect(second_request).to eq(2)
        end

        it 'sets the load curve in frame 0 to 5.0' do
          expect(producer.load_curve.get(0)).to eq(5.0)
        end

        it 'permits no further requests' do
          expect(producer.request(0, 1.0)).to eq(0)
        end
      end

      context 'requesting 5.0 in frame 1' do
        let!(:next_request) { producer.request(1, 5.0) }

        it 'returns 2.0' do
          expect(next_request).to eq(5)
        end

        it 'sets the load curve in frame 1 to 5.0' do
          expect(producer.load_curve.get(1)).to eq(5.0)
        end
      end
    end
  end
end
