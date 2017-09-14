require 'spec_helper'

RSpec.describe Fever::DeferrableActivity do
  let(:producer) { Fever::Producer.new(2.0) }
  let(:activity) { Fever::DeferrableActivity.new(producer, expire_after: 2) }

  context 'with capacity of 2.0 and expiry after 2 frames' do
    context 'demand of 2.2 for four frames' do
      before do
        (0..1).each { |frame| activity.request(frame, 2.2) }
        (2..3).each { |frame| activity.request(frame, 0.0) }
      end

      it 'has production of 2.0 in frame 0' do
        expect(producer.output_at(0)).to eq(2.0)
      end

      it 'has production of 2.0 in frame 1' do
        expect(producer.output_at(1)).to eq(2.0)
      end

      it 'has production of 0.4 in frame 2' do
        expect(producer.output_at(2)).to be_within(1e-8).of(0.4)
      end

      it 'has no production in frame 3' do
        expect(producer.output_at(3)).to eq(0.0)
      end

      it 'has activity demand of 4.4' do
        # 2.2 in two frames, 0.0 in two. Deferred demands are not counted twice.
        expect(activity.demand).to eq(4.4)
      end
    end

    context 'demand of 2.6 for four frames' do
      # id = instantaneous demand
      # if = instantaneous demand fulfilled
      # df = deferred demand fulfilled
      # d  = amount deferred + expiry frame
      #
      # n | id. | df. | if. | d.      |
      # 0 | 2.6 | 0.0 | 2.0 | 0.6 (2) | = 2.0
      # 1 | 2.6 | 0.6 | 1.4 | 1.2 (3) | = 2.0
      # 2 | 2.6 | 1.2 | 0.8 | 1.8 (4) | = 2.0
      # 3 | 2.6 | 1.8 | 0.2 | 2.4 (5) | = 2.0
      # 4 | 0.0 | 2.0 | 0.0 | 0.4 (5) | = 2.0
      # 5 | 0.0 | 0.4 | 0.0 | 0.0     | = 0.4
      # 6 | 0.0 | 0.0 | 0.0 | 0.0     | = 0.0
      before do
        (0..3).each { |frame| activity.request(frame, 2.6) }
        (4..6).each { |frame| activity.request(frame, 0.0) }
      end

      it 'has production of 2.0 in frames 0..3' do
        expect(Array.new(4) { |frame| producer.output_at(frame) })
          .to eq([2.0] * 4)
      end

      it 'has production of 2.0 in frame 4' do
        expect(producer.output_at(4)).to eq(2.0)
      end

      it 'has production of 0.4 in frame 5' do
        expect(producer.output_at(5)).to be_within(1e-8).of(0.4)
      end

      it 'has no production in frame 6' do
        expect(producer.output_at(6)).to eq(0.0)
      end
    end

    context 'demand of 10.0 for one frame ' do
      # id = instantaneous demand
      # if = instantaneous demand fulfilled
      # df = deferred demand fulfilled
      # d  = amount deferred + expiry frame
      #
      # n | id.  | df. | if. | d.      |
      # 0 | 10.0 | 0.0 | 2.0 | 8.0 (2) | = 2.0
      # 1 |  0.0 | 2.0 | 0.0 | 6.0 (2) | = 2.0
      # 2 |  0.0 | 2.0 | 0.0 | 4.0 (2) | = 2.0
      # 3 |  0.0 | 0.0 | 0.0 |       - | = 0.0
      before do
        activity.request(0, 10.0)
        (1..3).each { |frame| activity.request(frame, 0.0) }
      end

      it 'has production of 2.0 in frame 0' do
        expect(producer.output_at(0)).to eq(2.0)
      end

      it 'has production of 2.0 in frame 1' do
        expect(producer.output_at(1)).to eq(2.0)
      end

      it 'has production of 2.0 in frame 2' do
        expect(producer.output_at(2)).to eq(2.0)
      end

      it 'has no production in frame 3' do
        expect(producer.output_at(3)).to eq(0.0)
      end
    end
  end # with capacity of 2.0 and expiry after 2 frames

  context 'with capacity of 2.0 and expiry after 1 frame' do
    let(:activity) { Fever::DeferrableActivity.new(producer, expire_after: 1) }

    context 'demand of 10.0 for one frame' do
      # id = instantaneous demand
      # if = instantaneous demand fulfilled
      # df = deferred demand fulfilled
      # d  = amount deferred + expiry frame
      #
      # n | id.  | df. | if. | d.      |
      # 0 | 10.0 | 0.0 | 2.0 | 8.0 (2) | = 2.0
      # 1 |  0.0 | 2.0 | 0.0 | 6.0 (2) | = 2.0
      # 2 |  0.0 | 2.0 | 0.0 |       - | = 0.0
      before do
        activity.request(0, 10.0)
        activity.request(1, 0.0)
        activity.request(1, 0.0)
      end

      it 'has production of 2.0 in frame 0' do
        expect(producer.output_at(0)).to eq(2.0)
      end

      it 'has production of 2.0 in frame 1' do
        expect(producer.output_at(1)).to eq(2.0)
      end

      it 'has no production in frame 2' do
        expect(producer.output_at(2)).to eq(0.0)
      end
    end
  end # with capacity of 2.0 and expiry after 2 frames

  context 'with share of 0.5' do
    let(:activity) do
      Fever::DeferrableActivity.new(producer, expire_after: 2, share: 0.5)
    end

    it 'sets the share' do
      expect(activity.share).to eq(0.5)
    end
  end
end
