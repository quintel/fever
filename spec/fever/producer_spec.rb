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
        expect(producer.load_at(0)).to eq(3)
      end

      it 'has input of 3.0' do
        expect(producer.input_at(0)).to eq(3)
      end

      context 'when requesting another 1.0' do
        let!(:second_request) { producer.request(0, 1.0) }

        it 'returns 1.0' do
          expect(second_request).to eq(1)
        end

        it 'sets the load curve in frame 0 to 4.0' do
          expect(producer.load_at(0)).to eq(4.0)
        end

        it 'has input of 4.0' do
          expect(producer.input_at(0)).to eq(4.0)
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
          expect(producer.load_at(0)).to eq(5.0)
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
          expect(producer.load_at(0)).to eq(5.0)
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
          expect(producer.load_at(1)).to eq(5.0)
        end
      end
    end
  end # with a capacity of 5.0

  context 'with a capacity of 6.0 and input efficiency 0.75' do
    let(:producer) { Fever::Producer.new(6.0, input_efficiency: 0.75) }

    context 'requesting 3.0 in frame 0' do
      let!(:request) { producer.request(0, 3.0) }

      it 'returns 3.0' do
        expect(request).to eq(3)
      end

      it 'has input of 4.0' do
        expect(producer.input_at(0)).to eq(4)
      end
    end

    context 'requesting 3.0 in frame 1' do
      let!(:request) { producer.request(1, 3.0) }

      it 'returns 3.0' do
        expect(request).to eq(3)
      end

      it 'has input of 4.0' do
        expect(producer.input_at(1)).to eq(4)
      end
    end

    context 'requesting 10.0 in frame 0' do
      let!(:request) { producer.request(0, 10.0) }

      it 'returns 6.0' do
        expect(request).to eq(6)
      end

      it 'has input of 8.0' do
        expect(producer.input_at(0)).to eq(8.0)
      end
    end
  end # with a capacity of 6.0 and input efficiency 0.75

  context 'with a capacity of 6.0 and input efficiency [1, 0.5, 0.25]' do
    let(:producer) do
      Fever::Producer.new(6.0, input_efficiency: [1, 0.5, 0.25])
    end

    context 'requesting 1.0 in frame 0' do
      let!(:request) { producer.request(0, 1.0) }

      it 'has input of 1.0' do
        expect(producer.input_at(0)).to eq(1)
      end
    end

    context 'requesting 1.0 in frame 1' do
      let!(:request) { producer.request(1, 1.0) }

      it 'has input of 2.0' do
        expect(producer.input_at(1)).to eq(2)
      end
    end

    context 'requesting 1.0 in frame 2' do
      let!(:request) { producer.request(2, 1.0) }

      it 'has input of 4.0' do
        expect(producer.input_at(2)).to eq(4)
      end
    end
  end # with a capacity of 6.0 and input efficiency [1, 0.5, 0.25]
end
