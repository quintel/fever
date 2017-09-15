require 'spec_helper'

module Fever
  RSpec.describe BufferingProducer do
    describe 'with an output capacity of 5.0 and a reserve volume of 10.0' do
      let(:reserve)  { Merit::Flex::Reserve.new(10.0) }
      let(:producer) { BufferingProducer.new(5.0, reserve) }

      context 'when empty' do
        describe 'requesting nothing' do
          let(:request) { producer.request(0, 0.0) }

          it 'returns 0.0' do
            expect(request).to eq(0.0)
          end

          it 'sets the output curve to 0.0' do
            expect { request }.not_to change { producer.output_at(0) }.from(0)
          end

          it 'sets the source to 5.0' do
            expect { request }.to change { producer.source_at(0) }.from(0).to(5)
          end

          it 'adds 5.0 to the reserve' do
            expect { request }.to change { reserve.at(0) }.from(0).to(5)
          end
        end

        describe 'requesting 3.0' do
          let(:request) { producer.request(0, 3.0) }

          it 'returns 3.0' do
            expect(request).to eq(3.0)
          end

          it 'sets the output curve to 3.0' do
            expect { request }.to change { producer.output_at(0) }.from(0).to(3)
          end

          it 'sets the source to 5.0' do
            expect { request }.to change { producer.source_at(0) }.from(0).to(5)
          end

          it 'adds 2.0 to the reserve' do
            expect { request }.to change { reserve.at(0) }.from(0).to(2)
          end
        end

        describe 'requesting 6.0' do
          let(:request) { producer.request(0, 6.0) }

          it 'returns 5.0' do
            expect(request).to eq(5.0)
          end

          it 'sets the output curve to 5.0' do
            expect { request }.to change { producer.output_at(0) }.from(0).to(5)
          end

          it 'sets the source to 5.0' do
            expect { request }.to change { producer.source_at(0) }.from(0).to(5)
          end

          it 'adds nothing to the reserve' do
            expect { request }.not_to change { reserve.at(0) }.from(0)
          end
        end
      end # when empty

      context 'with 7.5 stored' do
        before { reserve.add(0, 7.5) }

        describe 'requesting nothing' do
          let(:request) { producer.request(1, 0.0) }

          it 'returns 0.0' do
            expect(request).to eq(0.0)
          end

          it 'sets the output curve to 0.0' do
            expect { request }.not_to change { producer.output_at(1) }.from(0)
          end

          it 'sets the source to 2.5' do
            expect { request }
              .to change { producer.source_at(1) }.from(0).to(2.5)
          end

          it 'adds 2.5 to the reserve (total = 10)' do
            expect { request }.to change { reserve.at(1) }.from(7.5).to(10)
          end
        end

        describe 'requesting 2.5' do
          let(:request) { producer.request(1, 2.5) }

          it 'returns 2.5' do
            expect(request).to eq(2.5)
          end

          it 'sets the output curve to 2.5' do
            expect { request }
              .to change { producer.output_at(1) }
              .from(0).to(2.5)
          end

          it 'sets the source to 5.0' do
            # start = 7.5, taken 2.5, added 5.0 (volume limited)
            expect { request }.to change { producer.source_at(1) }.from(0).to(5)
          end

          it 'adds 2.5 to the reserve (total = 10)' do
            expect { request }.to change { reserve.at(1) }.from(7.5).to(10)
          end
        end

        # Exceeds output capacity, but the reserve is not constrainted by the
        # output capacity of the producer.
        describe 'requesting 10.0' do
          let(:request) { producer.request(1, 10.0) }

          it 'returns 10.0' do
            expect(request).to eq(10.0)
          end

          it 'sets the output curve to 10.0' do
            expect { request }
              .to change { producer.output_at(1) }
              .from(0).to(10)
          end

          it 'sets the source to 2.5' do
            # start = 7.5, taken 7.5, 2.5 used instantaneously,
            # added 2.5 (capacity limited)
            expect { request }.to change { producer.source_at(1) }.from(0).to(5)
          end

          it 'removes 5.0 from the reserve' do
            expect { request }.to change { reserve.at(1) }.from(7.5).to(2.5)
          end
        end

        describe 'requesting 15.0' do
          let(:request) { producer.request(1, 15.0) }

          it 'returns 12.5' do
            expect(request).to eq(12.5)
          end

          it 'sets the output curve to 12.5' do
            expect { request }
              .to change { producer.output_at(1) }.from(0).to(12.5)
          end

          it 'sets the source to 5.0' do
            expect { request }.to change { producer.source_at(1) }.from(0).to(5)
          end

          it 'removes everything from the reserve' do
            expect { request }.to change { reserve.at(1) }.from(7.5).to(0)
          end
        end
      end # with 7.5 stored
    end # with an output capacity of 5.0 and a reserve volume of 10.0

    context 'with an output capacity of [5.0, 2.5, ...] and 1.0 stored' do
      let(:reserve)  { Merit::Flex::Reserve.new(1.0) }
      let(:producer) { BufferingProducer.new([5.0, 2.5], reserve) }

      before { reserve.add(0, 1.0) }

      context 'requesting 4.0 in frame 0' do
        let!(:request) { producer.request(0, 4.0) }

        it 'returns 4.0' do
          expect(request).to eq(4)
        end

        it 'sets the output curve in frame 0 to 4.0' do
          expect(producer.output_at(0)).to eq(4)
        end

        it 'has source of 4.0' do
          expect(producer.source_at(0)).to eq(4)
        end
      end

      context 'requesting 4.0 in frame 1' do
        let!(:request) { producer.request(1, 4.0) }

        it 'returns 3.5' do
          expect(request).to eq(3.5)
        end

        it 'sets the output curve in frame 0 to 3.5' do
          expect(producer.output_at(1)).to eq(3.5)
        end

        it 'has source of 2.5' do
          expect(producer.source_at(1)).to eq(2.5)
        end
      end
    end # with a capacity of [5.0, 2.5, ...] and 1.0 stored

  end
end # Fever
