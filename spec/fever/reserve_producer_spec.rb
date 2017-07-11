require 'spec_helper'

RSpec.describe Fever::ReserveProducer do
  describe 'with a capacity of 5.0 and reserve volume of 10.0' do
    let(:reserve) { Merit::Flex::Reserve.new(10.0) }
    let(:producer) { Fever::ReserveProducer.new(5.0, reserve) }

    context 'when empty' do
      it 'denies a request for 0.0' do
        expect(producer.request(0, 0.0)).to eq(0.0)
      end

      it 'denies a request for 1.0' do
        expect(producer.request(0, 1.0)).to eq(0.0)
      end
    end

    context 'with 2.5 stored' do
      before { reserve.add(0, 2.5) }

      context 'requesting 2.5' do
        let(:request) { producer.request(0, 2.5) }

        it 'returns 2.5' do
          expect(request).to eq(2.5)
        end

        it 'has a load of 2.5' do
          expect { request }
            .to change { producer.load_at(0) }.from(0).to(2.5)
        end

        it 'reduces stored energy to 0.0' do
          expect { request }
            .to change { reserve.at(0) }.from(2.5).to(0)
        end
      end

      context 'requesting 5.0' do
        let(:request) { producer.request(0, 5.0) }

        it 'returns 2.5' do
          expect(request).to eq(2.5)
        end

        it 'has a load of 2.5' do
          expect { request }
            .to change { producer.load_at(0) }.from(0).to(2.5)
        end

        it 'reduces stored energy to 0.0' do
          expect { request }
            .to change { reserve.at(0) }.from(2.5).to(0)
        end
      end
    end # with 2.5 stored

    context 'with 7.5 stored' do
      before { reserve.add(0, 7.5) }

      context 'requesting 2.0' do
        let(:request) { producer.request(0, 2.0) }

        it 'returns 2.0' do
          expect(request).to eq(2.0)
        end

        it 'has a load of 2.0' do
          expect { request }
            .to change { producer.load_at(0) }.from(0).to(2.0)
        end

        it 'reduces stored energy to 5.5' do
          expect { request }
            .to change { reserve.at(0) }.from(7.5).to(5.5)
        end

        context 'then requesting 2.5' do
          before { request }
          let(:second_request) { producer.request(0, 2.5) }

          it 'returns 2.5' do
            expect(second_request).to eq(2.5)
          end

          it 'has a load of 4.5' do
            expect { second_request }
              .to change { producer.load_at(0) }.from(2.0).to(4.5)
          end

          it 'reduces stored energy to 3.0' do
            expect { second_request }
              .to change { reserve.at(0) }.from(5.5).to(3.0)
          end
        end
      end

      context 'requesting 5.0' do
        let(:request) { producer.request(0, 5.0) }

        it 'returns 5.0' do
          expect(request).to eq(5.0)
        end

        it 'has a load of 5.0' do
          expect { request }
            .to change { producer.load_at(0) }.from(0).to(5.0)
        end

        it 'reduces stored energy to 2.5' do
          expect { request }
            .to change { reserve.at(0) }.from(7.5).to(2.5)
        end

        context 'then requesting 2.5' do
          before { request }
          let(:second_request) { producer.request(0, 2.5) }

          it 'denies the request' do
            expect(second_request).to eq(0)
          end

          it 'does not change the producer load' do
            expect { second_request }
              .not_to change { producer.load_at(0) }.from(5.0)
          end

          it 'does not reduce stored energy' do
            expect { second_request }
              .not_to change { reserve.at(0) }.from(2.5)
          end
        end
      end

      context 'requesting 7.5' do
        let(:request) { producer.request(0, 7.5) }

        it 'returns 5.0' do
          expect(request).to eq(5.0)
        end

        it 'has a load of 5.0' do
          expect { request }
            .to change { producer.load_at(0) }.from(0).to(5.0)
        end

        it 'reduces stored energy to 2.5' do
          expect { request }
            .to change { reserve.at(0) }.from(7.5).to(2.5)
        end
      end
    end # with 7.5 stored
  end # with a capacity of 5.0 and reserve volume of 10.0
end
