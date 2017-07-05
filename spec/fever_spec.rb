require 'spec_helper'

RSpec.describe Fever do
  it 'has a version number' do
    expect(Fever::VERSION).not_to be nil
  end

  describe '#curve' do
    context 'given an array' do
      let(:array) { [1.0, 3.0, 5.0] }

      it 'returns a Merit::Curve' do
        expect(Fever.curve(array)).to be_a(Merit::Curve)
      end

      it 'has the same values as the array' do
        expect(Fever.curve(array).to_a).to eq(array)
      end
    end

    context 'given a Merit::Curve' do
      let(:curve) { Merit::Curve.new([1.0, 3.0, 5.0]) }

      it 'returns a Merit::Curve' do
        expect(Fever.curve(curve)).to be_a(Merit::Curve)
      end

      it 'returns the same object it was given' do
        expect(Fever.curve(curve).object_id).to eq(curve.object_id)
      end
    end

    context 'given a non-enum' do
      it 'raises an error' do
        expect { Fever.curve('') }.to raise_error(NoMethodError)
      end
    end
  end
end
