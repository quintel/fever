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
        expect(consumer.load_at(0)).to eq(1.0)
      end

      it 'sets the producer load to 1.0' do
        expect(producer.load_at(0)).to eq(1.0)
      end
    end

    describe 'total demand of 2.0' do
      let!(:result) { calculator.calculate_frame(1) }

      it 'sets the consumer load to 1.5' do
        expect(consumer.load_at(1)).to eq(1.5)
      end

      it 'sets the producer load to 1.5' do
        expect(producer.load_at(1)).to eq(1.5)
      end
    end
  end # with producer capacity 1.5

  context 'with producer capacity 1.5, share 0.5' do
    let(:activity) { Fever::Activity.new(producer, share: 0.5) }

    context 'total demand of 1.0' do
      let!(:result) { calculator.calculate_frame(0) }

      it 'sets the consumer load to 0.5' do
        expect(consumer.load_at(0)).to eq(0.5)
      end

      it 'sets the producer load to 0.5' do
        expect(producer.load_at(0)).to eq(0.5)
      end
    end

    describe 'total demand of 2.0' do
      let!(:result) { calculator.calculate_frame(1) }

      it 'sets the consumer load to 1.0' do
        expect(consumer.load_at(1)).to eq(1.0)
      end

      it 'sets the producer load to 1.0' do
        expect(producer.load_at(1)).to eq(1.0)
      end
    end

    describe 'total demand of 4.0' do
      let!(:result) { calculator.calculate_frame(2) }

      it 'sets the consumer load to 1.5' do
        expect(consumer.load_at(2)).to eq(1.5)
      end

      it 'sets the producer load to 1.5' do
        expect(producer.load_at(2)).to eq(1.5)
      end
    end
  end # with producer capacity 1.5, share 0.5

  context 'with two producers in separate groups, capacity 2.0, ' \
          'shares 1.0 and 0.5' do
    let(:prod1) { Fever::Producer.new(2.0) }
    let(:prod2) { Fever::Producer.new(2.0) }

    let(:calculator) do
      Fever::Calculator.new(consumer, [
        [Fever::Activity.new(prod1, share: 1.0)],
        [Fever::Activity.new(prod2, share: 0.5)]
      ])
    end

    describe 'total demand of 1.0' do
      let!(:result) { calculator.calculate_frame(0) }

      it 'assigns 1.0 to the first producer' do
        expect(prod1.load_at(0)).to eq(1.0)
      end

      it 'assigns 0.0 to the first producer' do
        expect(prod2.load_at(0)).to eq(0.0)
      end
    end

    describe 'total demand of 2.0' do
      let!(:result) { calculator.calculate_frame(1) }

      it 'assigns 2.0 to the first producer' do
        expect(prod1.load_at(1)).to eq(2.0)
      end

      it 'assigns 0.0 to the first producer' do
        expect(prod2.load_at(1)).to eq(0.0)
      end
    end

    describe 'total demand of 4.0' do
      let!(:result) { calculator.calculate_frame(2) }

      it 'assigns 2.0 to the first producer' do
        expect(prod1.load_at(2)).to eq(2.0)
      end

      it 'assigns 1.0 to the first producer' do
        # 2.0 demand remains after prod1, this activity has a share of 0.5
        expect(prod2.load_at(2)).to eq(1.0)
      end
    end
  end

  context 'with two reserve producers, capacity 2.0' do
    let(:prod1) do
      Fever::ReserveProducer.new(10.0, Merit::Flex::Reserve.new(10.0), input_capacity: 2.0)
    end

    let(:prod2) do
      Fever::ReserveProducer.new(10.0, Merit::Flex::Reserve.new(10.0), input_capacity: 2.0)
    end

    let(:calculator) do
      Fever::Calculator.new(consumer, [
        Fever::Activity.new(prod1, share: 0.5),
        Fever::Activity.new(prod2, share: 0.5)
      ])
    end

    context 'storing 3.0' do
      let(:store_excess) { calculator.store_excess(0, 3.0) }

      it 'assigns 2.0 to the first producer' do
        expect { store_excess }.to change { prod1.reserve.at(0) }.from(0).to(2)
      end

      it 'assigns 1.0 to the second producer' do
        expect { store_excess }.to change { prod2.reserve.at(0) }.from(0).to(1)
      end
    end

    context 'storing 5.0' do
      let(:store_excess) { calculator.store_excess(0, 5.0)}

      it 'assigns 2.0 to the first producer' do
        expect { store_excess }.to change { prod1.reserve.at(0) }.from(0).to(2)
      end

      it 'assigns 2.0 to the second producer' do
        expect { store_excess }.to change { prod2.reserve.at(0) }.from(0).to(2)
      end
    end
  end
end
