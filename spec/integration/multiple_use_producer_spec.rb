require 'spec_helper'

module Fever
  RSpec.describe 'Producer (production=10.0) used for multiple consumers' do
    let(:producer) { Producer.new(10.0) }

    let(:act_one)  { Activity.new(producer) }
    let(:act_two)  { Activity.new(producer) }

    let(:calc_one) { Calculator.new(Consumer.new([cons_one]), [act_one]) }
    let(:calc_two) { Calculator.new(Consumer.new([cons_two]), [act_two]) }

    context 'when assigning 5.0 to the first activity' do
      let(:cons_one) { 5.0 }
      let!(:first_request) { calc_one.calculate_frame(0) }

      it 'sets the producer load to 5.0' do
        expect(producer.load_at(0)).to eq(5.0)
      end

      it 'sets the first activity consumption to 5.0' do
        expect(calc_one.consumer.load_at(0)).to eq(5.0)
      end

      context 'assigning 2.0 to the second activity' do
        let(:cons_two) { 2.0 }
        let!(:second_request) { calc_two.calculate_frame(0) }

        it 'sets the producer load to 7.0' do
          expect(producer.load_at(0)).to eq(7.0)
        end

        it 'sets the second activity consumption to 2.0' do
          expect(calc_two.consumer.load_at(0)).to eq(2.0)
        end

        it 'does not change the first activity consumption' do
          expect(calc_one.consumer.load_at(0)).to eq(5.0)
        end
      end

      context 'assigning 5.0 to the second activity' do
        let(:cons_two) { 2.0 }
        let!(:second_request) { calc_two.calculate_frame(0) }

        it 'sets the producer load to 10.0' do
          expect(producer.load_at(0)).to eq(7.0)
        end

        it 'sets the second activity consumption to 2.0' do
          expect(calc_two.consumer.load_at(0)).to eq(2.0)
        end

        it 'does not change the first activity consumption' do
          expect(calc_one.consumer.load_at(0)).to eq(5.0)
        end
      end

      context 'assigning 10.0 to the second activity' do
        let(:cons_two) { 5.0 }
        let!(:second_request) { calc_two.calculate_frame(0) }

        it 'sets the producer load to 10.0' do
          expect(producer.load_at(0)).to eq(10.0)
        end

        it 'sets the second activity consumption to 5.0' do
          expect(calc_two.consumer.load_at(0)).to eq(5.0)
        end

        it 'does not change the first activity consumption' do
          expect(calc_one.consumer.load_at(0)).to eq(5.0)
        end
      end
    end
  end # Producer (production=10.0) used for multiple consumers
end # Fever
