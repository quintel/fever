require 'spec_helper'

RSpec.describe Fever do
  it 'has a version number' do
    expect(Fever::VERSION).not_to be nil
  end

  describe '.curve' do
    let(:curve) { Fever.curve(input) }

    context 'given an array of 3 elements' do
      let(:input) { [1.0, 3.0, 5.0] }

      it 'returns an Array' do
        expect(curve).to be_a(Array)
      end

      it 'starts with the same values as the array' do
        expect(curve.take(3)).to eq(input)
      end

      it 'has Fever::FRAMES length' do
        expect(curve.length).to eq(Fever::FRAMES)
      end

      it 'defaults uninitialized values to zero' do
        expect(curve.drop(3)).to eq([0.0] * (Fever::FRAMES - 3))
      end
    end

    context 'given a correct-length Array' do
      let(:input) { Array.new(Fever::FRAMES, 1.0) }

      it 'returns a different object' do
        expect(curve.object_id).not_to eq(input.object_id)
      end

      it 'contains the original values' do
        expect(curve).to eq(input)
      end
    end

    context 'when input length exceeds Fever::FRAMES' do
      let(:input) { Array.new(Fever::FRAMES + 1, 1.0) }

      it 'raises an error' do
        expect { curve }.to raise_error(ArgumentError, /too many/)
      end
    end

    context 'given a Merit::Curve' do
      let(:input) do
        Merit::Curve.new([1.0, 3.0, 5.0, 7.0] * (Fever::FRAMES / 4))
      end

      it 'returns an array' do
        expect(curve).to be_a(Array)
      end

      it 'contains the original values' do
        expect(curve).to eq(input.to_a)
      end
    end

    context 'given a Merit::Curve with a default' do
      let(:input) do
        Merit::Curve.new([], Fever::FRAMES, 2.0)
      end

      it 'returns an array' do
        expect(curve).to be_a(Array)
      end

      it 'initialized the default values' do
        expect(curve).to eq([2.0] * Fever::FRAMES)
      end
    end

    context 'given a numeric' do
      let(:input) { 2.0 }

      it 'returns an array' do
        expect(curve).to be_an(Array)
      end

      it 'has Fever::FRAMES length' do
        expect(curve.length).to eq(Fever::FRAMES)
      end

      it 'initialized each value to equal the numeric' do
        expect(curve.all? { |v| v == input }).to be(true)
      end
    end

    context 'given a non-enum' do
      it 'raises an error' do
        expect { Fever.curve('') }
          .to raise_error(ArgumentError, /cannot create a curve from/)
      end
    end
  end

  describe '.empty_curve' do
    it 'returns an Array' do
      expect(Fever.empty_curve).to be_an(Array)
    end

    it 'has a length equal to Fever::FRAMES' do
      expect(Fever.empty_curve.length).to eq(Fever::FRAMES)
    end

    it 'has defaults values to zero' do
      expect(Fever.empty_curve.to_a.all?(&:zero?)).to be_truthy
    end
  end
end
