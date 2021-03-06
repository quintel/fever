require 'spec_helper'

module Fever
  RSpec.describe CompositeProducer do
    let(:producer) { CompositeProducer.new([comp1, comp2]) }

    context 'with components of capacity 2.0 and 4.0' do
      let(:comp1) { Producer.new(2.0) }
      let(:comp2) { Producer.new(4.0) }

      context 'requesting 1.0' do
        let(:request) { producer.request(0, 1.0) }

        it 'returns 1.0' do
          expect(request).to eq(1.0)
        end

        it 'sets the producer output to 1.0' do
          expect { request }.to change { producer.output_at(0) }.from(0).to(1)
        end

        it 'sets the first component output to 1.0' do
          expect { request }.to change { comp1.output_at(0) }.from(0).to(1)
        end

        it 'sets the first component input to 1.0' do
          expect { request }.to change { comp1.input_at(0) }.from(0).to(1)
        end

        it 'assigns no output to the second component' do
          expect { request }.not_to change { comp2.output_at(0) }.from(0)
        end

        it 'assigns no input to the second component' do
          expect { request }.not_to change { comp2.input_at(0) }.from(0)
        end

        context 'requesting another 2.0' do
          before { request }
          let(:next_request) { producer.request(0, 2.0) }

          it 'returns 2.0' do
            expect(next_request).to eq(2)
          end

          it 'sets the producer output to 3.0' do
            expect { next_request }
              .to change { producer.output_at(0) }.from(1).to(3)
          end

          it 'sets the producer input to 3.0' do
            expect { next_request }
              .to change { producer.input_at(0) }.from(1).to(3)
          end

          it 'sets the first component output to 2.0' do
            expect { next_request }
              .to change { comp1.output_at(0) }.from(1).to(2)
          end

          it 'sets the second component output to 1.0' do
            expect { next_request }
              .to change { comp2.output_at(0) }.from(0).to(1)
          end
        end

        context 'requesting another 6.0' do
          before { request }
          let(:next_request) { producer.request(0, 6.0) }

          it 'returns 5.0' do
            expect(next_request).to eq(5)
          end

          it 'sets the producer output to 6.0' do
            expect { next_request }
              .to change { producer.output_at(0) }.from(1).to(6)
          end

          it 'sets the producer input to 6.0' do
            expect { next_request }
              .to change { producer.input_at(0) }.from(1).to(6)
          end

          it 'sets the first component output to 2.0' do
            expect { next_request }
              .to change { comp1.output_at(0) }.from(1).to(2)
          end

          it 'sets the second component output to 4.0' do
            expect { next_request }
              .to change { comp2.output_at(0) }.from(0).to(4)
          end
        end
      end # requesting 1.0
    end # with components of capacity 2.0 and 4.0
  end # describe CompositeProducer
end # Fever
